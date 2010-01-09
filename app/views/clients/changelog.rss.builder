xml.instruct!
xml.rss(:version => '2.0',
        'xmlns:sparkle' => 'http://www.andymatuschak.org/xml-namespaces/sparkle',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do
  xml.channel do
    xml.title("#{@client.name} Changelog")
    xml.link(changelog_client_url(@client))
    xml.description(@client.info)
    xml.language('en')
    @client.client_versions.each do |client_version|
      xml.item do
        xml.title("Version #{client_version.version}")
        xml.sparkle(:releaseNotesLink) do
          xml << release_notes_client_url(@client)
        end
        xml.pubDate(client_version.created_at)
        xml.enclosure(:url => download_client_version_url(client_version),
                      'sparkle:version' => client_version.version,
                      :length => client_version.download_file_size,
                      :type => client_version.download_content_type,
                      'sparkle:dsaSignature' => client_version.signature)
      end
    end
  end
end
