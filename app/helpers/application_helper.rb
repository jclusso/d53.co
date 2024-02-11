module ApplicationHelper

  def render_logo(**options)
    options = {
      class: class_names(
        "transition hover:opacity-80 inline-block h-20",
        options.delete(:class)
      )
    }
    link_to(root_path, **options) do
      image_tag 'd53-logo.svg', class: 'h-full'
    end
  end

end
