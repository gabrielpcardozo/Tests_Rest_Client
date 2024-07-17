require 'date'

class Helper_Date
  def self.format_brazilian_date(iso_date)
    date = DateTime.parse(iso_date)
    date.strftime('%d/%m/%Y %H:%M:%S')
  end
end