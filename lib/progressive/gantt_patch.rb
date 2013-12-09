module Progressive::GanttPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      def initialize_with_assignees(options={})
        initialize_without_assignees(options)
        @assignees = ''
      end

      def render_issues_with_assignees(issues, options={})
        @issue_ancestors = []
        issues.each do |i|
          subject_for_issue(i, options) unless options[:only] == :lines
          assignee_for_issue(i, options)
          line_for_issue(i, options) unless options[:only] == :subjects
          options[:top] += options[:top_increment]
          @number_of_rows += 1
          break if abort?
        end
        options[:indent] -= (options[:indent_increment] * @issue_ancestors.size)
      end

      def line_for_issue_with_subject(issue, options)
        if issue.is_a?(Issue) && (issue.due_before || options[:show_subject_lines])
          coords = coordinates(issue.start_date, issue.due_before, issue.done_ratio, options[:zoom])
          label = "#{issue.status.name} #{issue.done_ratio}%"
          case options[:format]
          when :html
            label += " - #{issue.subject}" if options[:show_subject_lines]
            html_task(options, coords,
                      :css => "task " + (issue.leaf? ? 'leaf' : 'parent'),
                      :label => label, :issue => issue,
                      :markers => !issue.leaf?)
          when :image
            image_task(options, coords, :label => label)
          when :pdf
            pdf_task(options, coords, :label => label)
        end
        else
          ''
        end
      end

      alias_method_chain :initialize,     :assignees
      alias_method_chain :render_issues,  :assignees
      alias_method_chain :line_for_issue, :subject

      # Renders the subjects of the Gantt chart, the left side.
      def assignees(options={})
        @assignees
      end

      def assignee_for_issue(issue, options)
        output = case options[:format]
        when :html
          css_classes = ''
          s = "".html_safe
          if issue.assigned_to.present?
            s << view.link_to_user(issue.assigned_to).html_safe
            assignee = view.content_tag(:span, s, :class => css_classes).html_safe
            html_assignee(options, assignee, :css => "issue-assignee",
                         :title => issue.assigned_to.name, :id => "user-#{issue.id}") + "\n"
          end
        # when :image
        #   image_subject(options, issue.subject)
        # when :pdf
        #   pdf_new_page?(options)
        #   pdf_subject(options, issue.subject)
        end
        output
      end

      def html_assignee(params, assignee, options={})
        style = "position: absolute;top:#{params[:top]}px;left:4px;"
        style << "width:#{params[:assignee_width]}px;" if params[:assignee_width]
        output = view.content_tag(:div, assignee,
                                  :class => options[:css], :style => style,
                                  :title => options[:title],
                                  :id => options[:id])
        @assignees << output
        output
      end

    end
  end
end

unless Redmine::Helpers::Gantt.include? Progressive::GanttPatch
  Redmine::Helpers::Gantt.send(:include, Progressive::GanttPatch)
end
