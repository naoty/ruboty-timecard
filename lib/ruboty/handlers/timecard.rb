require "date"

module Ruboty
  module Handlers
    class Timecard < Base
      DATE_FORMAT = "%Y-%m-%d"
      DATETIME_FORMAT = "%H:%M"
      SEPARATOR = " ~ "

      on //, all: true, name: "punch", description: "punch a timecard"

      def punch(message)
        @member = message.from || "Anonymous"
        storage[1, member_index] = @member
        storage[date_index, 1] = date_timestamp
        storage[date_index, member_index] = timestamp
      end

      private

      def storage
        robot.brain.data[0]
      end

      def member_index
        member_index = storage.rows[0].find_index(@member)
        if member_index.nil?
          storage.num_cols + 1
        else
          member_index + 1
        end
      end

      def date_index
        latest_date = Date.parse(storage[storage.num_rows, 1])
        latest_date == Date.today ? storage.num_rows : storage.num_rows + 1
      end

      def date_timestamp
        Time.now.strftime(DATE_FORMAT)
      end

      def timestamp
        [start_time, end_time].join(SEPARATOR)
      end

      def start_time
        value = storage[member_index, date_index]
        if value.empty?
          Time.now.strftime(DATETIME_FORMAT)
        else
          value.split(SEPARATOR).first
        end
      end

      def end_time
        Time.now.strftime(DATETIME_FORMAT)
      end
    end
  end
end