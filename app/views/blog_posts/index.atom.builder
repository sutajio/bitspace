atom_feed(:root_url => blog_url) do |feed|
  feed.title('Bitspace')
  feed.updated(@posts.first.created_at)

  @posts.each do |post|
    feed.entry(post, :url => blog_archive_url(post.year, post.month, post.slug)) do |entry|
      entry.title(post.title)
      entry.content(simple_format(post.body), :type => 'html')
      entry.author do |author|
        author.name('The Bitspace Group')
      end
    end
  end
end