require "iconv"
require "stringio"

require "mp3info"
require "ogginfo"
require "wmainfo"
require "mp4info"
require "flacinfo"

class AudioInfoError < Exception; end

class AudioInfo
  MUSICBRAINZ_FIELDS = { 
    "trmid" 	=> "TRM Id",
    "artistid" 	=> "Artist Id",
    "albumid" 	=> "Album Id",
    "albumtype"	=> "Album Type", 
    "albumstatus" => "Album Status",
    "albumartistid" => "Album Artist Id",
    "sortname" => "Sort Name",
    "trackid" => "Track Id"
  }

  SUPPORTED_EXTENSIONS = %w{mp3 ogg oga wma mp4 aac m4a flac}
  
  attr_reader :path, :extension, :musicbrainz_infos, :tracknum, :bitrate, :samplerate, :vbr
  attr_reader :artist, :album, :title, :length, :date, :year, :compilation, :album_artist, :setnum
  attr_reader :cover, :audio_content
  
  # "block version" of #new()
  def self.open(*args)
    audio_info = self.new(*args)
    ret = nil
    if block_given?
      begin
        ret = yield(audio_info)
      ensure
        audio_info.close
      end
    else
      ret = audio_info
    end
    ret
  end

  # open the file with path +fn+ and convert all tags from/to specified +encoding+
  def initialize(filename, options = {})
    raise(AudioInfoError, "path is nil") if filename.nil?
    @options = { :encoding => 'utf-8', :include_audio_content => false }.merge(options)
    @path = filename
    @extension = (@options[:extension] || File.extname(@path)[1..-1]).downcase
    @encoding = @options[:encoding]
    @musicbrainz_infos = {}

    begin
      case @extension
      when 'mp3'
        @info = Mp3Info.new(filename, :encoding => @encoding)
        default_tag_fill
        #"TXXX"=>
        #["MusicBrainz TRM Id\000",
        #"MusicBrainz Artist Id\000aba64937-3334-4c65-90a1-4e6b9d4d7ada",
        #"MusicBrainz Album Id\000e1a223c1-cbc2-427f-a192-5d22fefd7c4c",
        #"MusicBrainz Album Type\000album",
        #"MusicBrainz Album Status\000official",
        #"MusicBrainz Album Artist Id\000"]
          
        if (arr = @info.tag2["TXXX"]).is_a?(Array)
          fields = MUSICBRAINZ_FIELDS.invert
          arr.each do |val|
            if val =~ /^MusicBrainz (.+)\000(.*)$/
              short_name = fields[$1]
              @musicbrainz_infos[short_name] = $2
            end
          end
        end
        @bitrate = @info.bitrate
        @samplerate = @info.samplerate
        @vbr = @info.vbr
        i = @info.tag.tracknum
        @tracknum = (i.is_a?(Array) ? i.last : i).to_i
        @length = @info.length.to_i
        @date = @info.tag["date"]
        @compilation = @info.tag2['TCMP'] == '1'
        @album_artist = @info.tag2['TPE2']
        @setnum = @info.tag2['TPOS']
        @year = @info.tag.year.to_i == 0 ? nil : @info.tag.year.to_i
        @cover = self.class.image_from_id3_apic_tag(@info.tag2['APIC'])
        if @options[:include_audio_content]
          File.open(filename) do |f|
            f.seek(@info.audio_content.first)
            @audio_content = f.read(@info.audio_content.last)
          end
        end
        @info.close

      when 'ogg', 'oga'
        @info = OggInfo.new(filename, @encoding)
        default_fill_musicbrainz_fields
        default_tag_fill
        @bitrate = @info.bitrate/1000
        @tracknum = @info.tag.tracknumber.to_i
        @length = @info.length.to_i
        @date = @info.tag["date"]
        @vbr = true
        @info.close
        
        if @options[:include_audio_content]
          @audio_content = File.open(filename).read
        end

      when 'wma'
        @info = WmaInfo.new(filename, :encoding => @encoding)
        @artist = @info.tags["Author"]
        @album = @info.tags["AlbumTitle"]
        @title = @info.tags["Title"]
        @tracknum = @info.tags["TrackNumber"].to_i
        @date = @info.tags["Year"]
        @bitrate = @info.info["bitrate"]
        @length = @info.info["playtime_seconds"]
        MUSICBRAINZ_FIELDS.each do |key, original_key|
          @musicbrainz_infos[key] = 
                  @info.info["MusicBrainz/" + original_key.tr(" ", "")] ||
                  @info.info["MusicBrainz/" + original_key]
        end
        
        if @options[:include_audio_content]
          @audio_content = File.open(filename).read
        end

      when 'aac', 'mp4', 'm4a'
        @info = MP4Info.open(filename)
        @artist = @info.ART
        @album = @info.ALB
        @title = @info.NAM
        @tracknum = @info.TRKN ? @info.TRKN.first : nil
        @total_tracks = @info.TRKN ? @info.TRKN.last : nil
        @date = @info.DAY
        @compilation = @info.CPIL == 1
        @album_artist = @info.AART
        @setnum = @info.DISK ? @info.DISK.first : nil
        @total_disks = @info.DISK ? @info.DISK.last : nil
        @year = @info.DAY.to_i == 0 ? nil : @info.DAY.to_i
        @cover = @info.COVR
        @bitrate = @info.BITRATE
        @samplerate = @info.FREQUENCY*1000.0
        @length = @info.SECS
        @composer = @info.WRT
        @copyright = @info.CPRT
        @apple_store_id = @info.APID
        @comment = @info.CMT
        @rating = @info.RTNG
        @bpm = @info.TMPO
        @grouping = @info.GRP
        @genre = @info.GNRE
        
        if @options[:include_audio_content]
          @audio_content = File.open(filename).read
        end
  
      when 'flac'
        @info = FlacInfo.new(filename)
        tags = convert_tags_encoding(@info.tags, "UTF-8")
        @artist = tags["ARTIST"] || tags["artist"]
        @album = tags["ALBUM"] || tags["album"]
        @title = tags["TITLE"] || tags["title"]
        @tracknum = (tags["TRACKNUMBER"]||tags["tracknumber"]).to_i
        @date = tags["DATE"]||tags["date"]
        @length = @info.streaminfo["total_samples"] / @info.streaminfo["samplerate"].to_f
        @bitrate = File.size(filename).to_f*8/@length/1024
        tags.each do |tagname, tagvalue|
          next unless tagname =~ /^musicbrainz_(.+)$/
          @musicbrainz_infos[$1] = tags[tagname]
        end
        @musicbrainz_infos["trmid"] = tags["musicip_puid"]
        #default_fill_musicbrainz_fields
        
        if @options[:include_audio_content]
          @audio_content = File.open(filename).read
        end

      else
        raise(AudioInfoError, "unsupported extension '.#{@extension}'")
      end

      if @tracknum == 0
        @tracknum = nil
      end

      @musicbrainz_infos.delete_if { |k, v| v.nil? }

    rescue Exception, Mp3InfoError, OggInfoError => e
      if e.is_a?(Iconv::IllegalSequence)
        raise AudioInfoError, "Iconv::IllegalSequence", e.backtrace
      else
        raise AudioInfoError, e.to_s, e.backtrace
      end
    end
  end

  def close
    # do nothing
  end

=begin
   {"musicbrainz_albumstatus"=>"official",
    "artist"=>"Jill Scott",
    "replaygain_track_gain"=>"-3.29 dB",
    "tracknumber"=>"1",
    "title"=>"A long walk (A touch of Jazz Mix)..Jazzanova Love Beats...",
    "musicbrainz_sortname"=>"Scott, Jill",
    "musicbrainz_artistid"=>"b1fb6a18-1626-4011-80fb-eaf83dfebcb6",
    "musicbrainz_albumid"=>"cb2ad8c7-4a02-4e46-ae9a-c7c2463c7235",
    "replaygain_track_peak"=>"0.82040048",
    "musicbrainz_albumtype"=>"compilation",
    "album"=>"...Mixing (Jazzanova)",
    "musicbrainz_trmid"=>"1ecec0a6-c7c3-4179-abea-ef12dabc7cbd",
    "musicbrainz_trackid"=>"0a368e63-dddf-441f-849c-ca23f9cb2d49",
    "musicbrainz_albumartistid"=>"89ad4ac3-39f7-470e-963a-56509c546377"}>
=end

  # check if the file is correctly tagged by MusicBrainz
  def mb_tagged?
    ! @musicbrainz_infos.empty?
  end
  
  def compilation?
    @compilation
  end
  
  def content_type
    case @extension
    when 'mp3': 'audio/mpeg'
    when 'oga': 'audio/ogg'
    when 'ogg': 'application/ogg'
    when 'wma': 'audio/x-ms-wma'
    when 'm4a': 'audio/mp4'
    when 'aac': 'audio/mp4'
    when 'mp4': 'application/mp4'
    when 'flac': 'audio/x-flac'
    end
  end

  private 

  def sanitize(input)
    s = input.is_a?(Array) ? input.first : input
    s.gsub("\000", "")
  end

  def default_fill_musicbrainz_fields
    MUSICBRAINZ_FIELDS.keys.each do |field|
      val = @info.tag["musicbrainz_#{field}"]
      @musicbrainz_infos[field] = val if val
    end
  end

  def default_tag_fill(tag = @info.tag)
    %w{artist album title}.each do |v|
      instance_variable_set( "@#{v}".to_sym, sanitize(tag[v].to_s) )
    end
  end

  def convert_tags_encoding(tags_orig, from_encoding)
    tags = {}
    Iconv.open(@encoding, from_encoding) do |ic|
      tags_orig.inject(tags) do |hash, (k, v)| 
        if v.is_a?(String)
          hash[ic.iconv(k)] = ic.iconv(v)
        end
        hash
      end
    end
    tags
  end
  
  def self.image_from_id3_apic_tag(apic_tag)
    if apic_tag
      apic_tag = apic_tag.first if apic_tag.is_a?(Array)
      encoding, mime_type, type, desc = apic_tag.unpack('BZ*BZ*')
      StringIO.new(apic_tag[(4+mime_type.size+desc.size)..-1])
    end
  end
end
