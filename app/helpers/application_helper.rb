module ApplicationHelper

  def title
    "SIR TWEETS-A-LOT"
  end

  def is_active?(path)
    current_page?(path) ? "active_nav" : ""
  end

  def bootstrap_class_for flash_type
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-danger"
    when :alert
      "alert-warning"
    when :notice
      "alert-info"
    else
      flash_type.to_s
    end
  end

  def table_header_link(category, link_route, attribute)
    if params[:order].blank?    
      sort_order = "desc"
    else
      sort_order = params[:order].include?("asc") ? "desc" : "asc"
    end
    link_to category, link_route.call(order: "#{attribute}_#{sort_order}")
  end

  def generate_caret(sort_order)
    if sort_order.include?("asc")
      content_tag(:span, "", class: "caret")
    else
      content_tag(:span, class: "dropup") do
        content_tag(:span, "", class: "caret")
      end
    end
  end

end
