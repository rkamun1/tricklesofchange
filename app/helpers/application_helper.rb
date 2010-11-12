module ApplicationHelper
  
 # Return a title on a per-page basis.
  def title
    base_title = "Trickles of Change - Your tool to microsaving!!"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def logo
    image_tag("newheader.png", :alt => "Trickles of Change - Your tool to microsaving!!", :class => "round")
  end
end
