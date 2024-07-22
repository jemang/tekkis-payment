module ApplicationHelper

  def badge_tag(type, args = {})
    color = args[:color].presence || color(type, args[:outline].present?)
    klass = args[:class].presence || ""
    text = args[:text] || type.to_s&.humanize
    outline = args[:outline].present? ? "badge-outline" : ""
    content_tag(:span, class: "badge badge-sm #{outline} #{color} text-white #{klass}") do
      text || type.to_s&.humanize
    end
  end

  def color(type, outline = false)
    color_type = outline ? "text" : "bg"
    case type.to_s
    when "pending"
      "#{color_type}-info"
    when "expired"
      "#{color_type}-warning"
    when "rejected"
      "#{color_type}-danger"
    when "completed"
      "#{color_type}-success"
    when "processing"
      "#{color_type}-dark"
    else
      "#{color_type}-primary"
    end
  end
end
