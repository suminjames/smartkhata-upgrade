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

    # predefining style helpers
    border = {border: {style: :thin, color: "3c8dbc"}}
    border_right = {border: {style: :thin, color: "d2d6de", edges: [:right]}} #color: "808080"
    border_top_right = {border: {style: :thin, color: "d2d6de", edges: [:top, :right]}} #color: "00"
    bg_striped = {bg_color: "f9f9f9"}
    bg_grey = {bg_color: "d3d3d3"}
    bg_white = {bg_color: "FF"}
    h_center = {alignment: {horizontal: :center}}
    v_center = {alignment: {vertical: :center}}
    complete_center = h_center.deep_merge(v_center)
    left = {alignment: {horizontal: :left}}
    right = {alignment: {horizontal: :right}}
    muted = {fg_color: "808080"}
    center_clear = h_center.merge bg_white
    plain = bg_white.merge border_right
    separator = bg_white.merge border_top_right

    normal = border.merge v_center
    striped = normal.merge bg_striped

    doc_header_style = {sz: 20, fg_color: "3c8dbc"}.merge center_clear
    doc_sub_header_style = {sz: 14}.merge center_clear
    table_header_style = {b: true, sz: 12, bg_color: "3c8dbc", fg_color: "FF", border: Axlsx::STYLE_THIN_BORDER}.merge(complete_center)

    float = {num_fmt: 4}.merge normal
    int = {num_fmt: 1}.merge normal
    total = {b: true}.merge border
    wrap = {alignment: {wrap_text: true, vertical: :center}}

    # the actual styles to be defined (accessed via the hash keys)
    # note: the keys of the styles hash below (& thus related styles) are used by ALL child classes. Proceed with great caution befre modifying!
    styles_to_add = {
      table_header: table_header_style,

      info: center_clear.merge(border_right),
      blank: plain,
      heading: doc_header_style.merge(border_right),
      sub_heading: doc_sub_header_style.merge(border_right),
      separator: separator,

      normal_style: normal,
      normal_style_muted: normal.merge(muted),
      normal_center: normal.deep_merge(h_center),
      normal_right: normal.deep_merge(right),
      striped_style: striped,
      striped_style_muted: striped.merge(muted),
      striped_center: striped.deep_merge(h_center),
      striped_right: striped.deep_merge(right),

      wrap: normal.merge(wrap),
      wrap_striped: striped.merge(wrap),

      int_format: int,
      int_format_striped: int.merge(bg_striped),
      int_format_left: int.deep_merge(left),
      int_format_left_striped: int.deep_merge(left).merge(bg_striped),

      float_format: float,
      float_format_striped: float.merge(bg_striped),
      float_format_right: float.deep_merge(right),
      float_format_right_striped: float.deep_merge(right).merge(bg_striped),

      broker_info: left.merge(plain),
      total_values: total,
      total_values_float: total.merge(float),
      total_keyword: total.merge(right),

      # date_format: obj.add_style({format_code: 'YYYY-MM-DD'}.merge border)
      # date_format_striped: obj.add_style({format_code: 'YYYY-MM-DD'}.merge striped)
    }

    # the hook for injecting additional child-specific styles
    if defined? additional_styles
      # provide predefined style helpers
      # note: the keys of the helper hash below (& thus related styles) are used by some child classes, thus should not be changed arbitrarily!
      style_helpers = {
        border: border,
        border_right: border_right,
        border_top_right: border_top_right,
        bg_striped: bg_striped,
        bg_grey: bg_grey,
        bg_white: bg_white,
        h_center: h_center,
        v_center: v_center,
        complete_center: complete_center,
        left: left,
        right: right,
        muted: muted,
        center_clear: center_clear,
        plain: plain,
        separator: separator,
        normal: normal,
        striped: striped,
        doc_header_style: doc_header_style,
        doc_sub_header_style: doc_sub_header_style,
        table_header_style: table_header_style,
        float: float,
        int: int,
        total: total,
        wrap: wrap
      }

      # merge the additional styles hash returned
      styles_to_add.merge!(additional_styles(style_helpers))
    end

    @styles = styles_to_add.inject(Hash.new){|p,w| p[w[0]] = obj.add_style(w[1]); p}
  end

  # Adds document headings as provided
  # Params:
  # +sub_heading_present+:: whether to present the first 'additional info' as a sub-heading (i.e with larger font)
  # +additional_infos_come_after_custom_block+:: whether to display the additional_infos before or after the custom block provided
  #
  def add_document_headings_base(heading, *additional_infos, sub_heading_present: true, additional_infos_come_after_custom_block: true)
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

    if sub_heading_present && additional_infos.present?
      sub_heading = additional_infos.shift
      add_header_row(sub_heading, :sub_heading)
    end

    # Additional query info (eg.dates)
    yield if additional_infos_come_after_custom_block && block_given?

    if additional_infos.present?
      additional_infos.each { |info| add_header_row(info, :info) }
      add_blank_row
    end

    yield if !additional_infos_come_after_custom_block && block_given?

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
    # Deletes the temporary report file if file exists!
    File.delete(@path) if File.file?(@path)
  end

end
