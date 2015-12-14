#Doc : http://spreadsheet.rubyforge.org/files/GUIDE_txt.html

module ExportServices
  class DasboardExpoter
    def initialize
      @book = Spreadsheet::Workbook.new
      @sheet1 = book.create_worksheet(name: "Derniers évènements")
    end

    def export

      sheet1.row(0).default_format = Spreadsheet::Format.new(weight: :bold, size: 14)
      sheet1.row(0).push "Date", "Durée (min)", "Distance (metres)"

      sheet1.row(1).concat ["01/10/2015", "223", "2345"]
      sheet1.row(1).default_format = Spreadsheet::Format.new(size: 12)
      book.write 'tmp/sample.xls'
    end

    def export_tour(tour:)

    end

    private
    attr_reader :book, :sheet1
  end
end
