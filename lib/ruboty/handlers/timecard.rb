require "date"

module Ruboty
  module Handlers
    class Timecard < Base
      DATE_FORMAT = "%Y/%m/%d"
      DATETIME_FORMAT = "%H:%M"
      SEPARATOR = " ~ "

      on //, all: true, name: "punch", description: "punch a timecard"

      def punch(message)
        @member = message.from || "Anonymous"
        storage[member_row, member_column] = @member
        storage[date_row, date_column] = today_timestamp
        storage[date_row, member_column] = timestamp
      end

      private

      def storage
        robot.brain.data[0]
      end

      def member_row
        1
      end

      def member_column
        if storage.num_rows > 0
          member_index = storage.rows[0].find_index(@member)
          member_index.nil? ? storage.num_cols + 1 : member_index + 1
        else
          2
        end
      end

      def date_column
        1
      end

      def date_row
        begin
          latest_date = Date.parse(storage[storage.num_rows, 1])
          latest_date == Date.today ? storage.num_rows : storage.num_rows + 1
        rescue
          2
        end
      end

      def today_timestamp
        Time.now.strftime(DATE_FORMAT)
      end

      def timestamp
        [start_time, end_time].join(SEPARATOR)
      end

      def start_time
        value = storage[date_row, member_column]
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
