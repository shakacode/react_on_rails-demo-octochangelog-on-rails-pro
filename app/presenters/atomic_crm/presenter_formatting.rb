# frozen_string_literal: true

module AtomicCrm
  module PresenterFormatting
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper

    private

    def currency(amount)
      number_to_currency(amount, precision: 0)
    end

    def timestamp_label(value)
      value&.in_time_zone&.strftime("%b %-d") || "New"
    end

    def task_count_label(count)
      return "No open tasks" if count.zero?

      pluralize(count, "open task")
    end
  end
end
