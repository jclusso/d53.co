module FormsHelper
  def form_field_tag(&)
    tag.div class: "block", &
  end
end
