xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  xml.url do
    xml.loc "http://www.tricklesofchange.com"
    xml.priority 1.0
  end

  @faqs.each do |faq|
    xml.url do
      xml.loc faq_url(faq)
      xml.priority 0.9
    end
  end

end

