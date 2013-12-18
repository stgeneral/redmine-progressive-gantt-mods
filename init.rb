Redmine::Plugin.register :progressive_gantt_mods do
  name 'Progressive Gantt Modifications'
  author 'Dmitry Babenko'
  description 'Assignee column and variable columns width'
  version '0.0.2'
  url 'http://stgeneral.github.io/redmine-progressive-gantt-mods/'
  author_url 'https://github.com/stgeneral'

  settings :default => {
    'show_assignees'     => true,
    'show_subject_lines' => false,
    'subject_width'      => 330,
    'assignee_width'     => 130,
  }
end

require 'progressive/gantt_patch'
require 'progressive/sidebar_view_listener'
