class Reports::Excelsheet
  # To be used as a base class for individual excelsheet report generators!
  include CustomDateModule

  attr_reader :path
  attr_reader :error

  def initialize(*values)
    parameters = self.class.instance_method(:initialize).parameters
    values.each_with_index do |val, i|
      self.instance_variable_set("@#{parameters[i][1]}", val)
    end
    @date = ad_to_bs Date.today
    @column_count = self.class::TABLE_HEADER.count
    @last_column = @column_count-1 #starting from 0
    @doc_header_row_count = 0
  end

  def type
    # Excelsheet File type needed for send_file
    "application/vnd.ms-excel"
  end

  def generated_successfully?
    # Returns true if no error
    @error.nil?
  end

  def data_present_or_set_error(data, err_msg=nil)
    # Returns true if data supplied is not empty
    err_msg ||= "No data to generate report!"
    if data.present?
      true
    else
      @error = err_msg
      false
    end
  end

  def generate_excelsheet
    # generates the full report & sets file path for it.
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: "Sheet 1") do |sheet|
      @sheet = sheet
      workbook.styles do |s|
        define_styles(s)
        prepare_document

        populate_table_header #child method
        populate_data_rows #child method

        set_column_widths #child method
        merge_header_cells
      end
    end
    @path = "#{Rails.root}/tmp/#{@file_name}.xlsx"

    # required for numbers?
    package.use_shared_strings = true
    package.serialize @path
    # data = package.to_stream() #error error!!

    # @file = Tempfile.new('Excelsheet')
    # @file.write(data.read)
    # @file.close
    # @path = @file.path
  end

  def define_styles(obj)
    # Defines and adds necessary styles to the workbook styles object & sets their hash to @styles variable.

    # center_bordered = {alignment: {horizontal: :center}, border: {style: :thin, color: "000"}}
    border = {border: {style: :thin, color: "3c8dbc"}}
    border_right = {border: {style: :thin, color: "d2d6de", edges: [:right]}} #color: "808080"
    border_top_right = {border: {style: :thin, color: "d2d6de", edges: [:top, :right]}} #color: "00"
    bg_striped = {bg_color: "f9f9f9"}
    bg_white = {bg_color: "FF"}
    h_center = {alignment: {horizontal: :center}}
    v_center = {alignment: {vertical: :center}}
    complete_center = {alignment: {horizontal: :center, vertical: :center}}
    v_center_right= {alignment: {horizontal: :right, vertical: :center}}
    v_center_left= {alignment: {horizontal: :left, vertical: :center}}
    left = {alignment: {horizontal: :left}}
    right = {alignment: {horizontal: :right}}
    muted = {fg_color: "808080"}
    center_clear = h_center.merge bg_white
    plain = bg_white.merge border_right
    separator = bg_white.merge border_top_right
    # center_bordered = center.merge border_right

    normal = border.merge v_center
    striped = normal.merge bg_striped

    doc_header_style = {sz: 20, fg_color: "3c8dbc"}.merge center_clear
    doc_sub_header_style = {sz: 14}.merge center_clear

    float = {num_fmt: 4}
    int = {num_fmt: 1}
    total = {b: true}.merge border
    wrap = {alignment: {wrap_text: true, vertical: :center}}
    float_right = float.merge v_center_right

    @styles = {
      table_header: obj.add_style({b: true, sz: 12, bg_color: "3c8dbc", fg_color: "FF", border: Axlsx::STYLE_THIN_BORDER}.merge complete_center),

      # date: [obj.add_style(center_clear)].insert(9, obj.add_style(center_clear.merge border_right)),
      info: obj.add_style(center_clear.merge border_right),
      blank: obj.add_style(plain),
      heading: obj.add_style(doc_header_style.merge border_right),
      sub_heading: obj.add_style(doc_sub_header_style.merge border_right),
      separator: obj.add_style(separator),

      normal_style: obj.add_style(normal),
      normal_style_muted: obj.add_style(normal.merge muted),
      normal_center: obj.add_style(border.merge complete_center),
      normal_right: obj.add_style(border.merge v_center_right),
      striped_style: obj.add_style(striped),
      striped_style_muted: obj.add_style(striped.merge muted),
      striped_center: obj.add_style(border.merge bg_striped.merge complete_center),
      striped_right: obj.add_style(border.merge bg_striped.merge v_center_right),

      wrap: obj.add_style(normal.merge wrap),
      wrap_striped: obj.add_style(striped.merge wrap),

      # date_format: obj.add_style({format_code: 'YYYY-MM-DD'}.merge border)
      # date_format_striped: obj.add_style({format_code: 'YYYY-MM-DD'}.merge striped)
      int_format: obj.add_style(int.merge normal),
      int_format_left: obj.add_style(int.merge border.merge v_center_left),
      int_format_striped: obj.add_style(int.merge striped),
      int_format_left_striped: obj.add_style(int.merge border.merge v_center_left.merge bg_striped),

      float_format: obj.add_style(float.merge normal),
      float_format_striped: obj.add_style(float.merge striped),
      float_format_right: obj.add_style(float_right.merge border),
      float_format_right_striped: obj.add_style(float_right.merge border.merge bg_striped),

      broker_info: obj.add_style(left.merge plain),
      total_values: obj.add_style(total),
      total_values_float: obj.add_style(total.merge float),
      total_keyword: obj.add_style(total.merge right)
    }

    # (local_variables-[:obj]).inject(Hash.new){|k,v| k[v] = eval(v.to_s); k}
  end

  def add_document_headings_base(heading, sub_heading, *additional_infos)
    # Current tenant info
    if t = @current_tenant
      broker_info = [t.full_name, t.broker_code, t.address, t.phone_number].select &:present?
      if broker_info.present?
        broker_info.each do |info|
          info.prepend "Broker No. " if info == t.broker_code
          add_header_row(info, :broker_info)
        end
        add_separator_row
      end
    end
    add_header_row(heading, :heading)
    add_blank_row
    add_header_row(sub_heading, :sub_heading)

    # Additional query info (eg.dates)
    yield if block_given?

    if additional_infos.present?
      additional_infos.each { |info| add_header_row(info, :info) }
      add_blank_row
    end

    # Report generated date
    add_header_row("Report Date: #{@date}", :info)
    add_blank_row
  end

  def add_header_row(text, style)
    # Adds a header row with in relevant manner
    @sheet.add_row [text].insert(@last_column, ''), style: @styles[style]
    @doc_header_row_count += 1
  end

  def add_blank_row
    add_header_row('', :blank)
  end

  def add_separator_row
    add_header_row('', :separator)
  end

  def populate_table_header
    # Adds table header row
    @sheet.add_row self.class::TABLE_HEADER, style: @styles[:table_header]
  end

  def merge_header_cells
    # Merges cells in each header row for clarity
    cell_ranges_to_merge = []

    last_col_alphabet = ('A'..'Z').to_a[@last_column]
    1.upto(@doc_header_row_count){|n| cell_ranges_to_merge << "A#{n}:#{last_col_alphabet}#{n}"}
    cell_ranges_to_merge.each { |range| @sheet.merge_cells(range) }
  end

  def file
    # Returns the report file object
    File.read(@path)
  end

  def filename
    # Returns the complete file name for the report
    "#{@file_name}.xlsx"
  end

  def clear
    # Deletes the temporary report file
    File.delete(@path) if File.file?(@path)
  end

end
