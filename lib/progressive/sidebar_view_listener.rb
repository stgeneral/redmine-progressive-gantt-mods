class Progressive::SidebarViewListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_sidebar, :partial => "progressive_gantt_sidebar"
end
