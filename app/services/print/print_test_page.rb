class Print::PrintTestPage < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  def initialize()
    super(top_margin: 12, right_margin: 28, bottom_margin: 18, left_margin: 18)
    test_page
  end

  def page_width
    578
  end

  def page_height
    770
  end

  def col (unit)
    unit / 12.0 * page_width
  end

  def hr
    pad_bottom(3) do
      stroke_horizontal_rule
    end
  end

  # Returns a page which can be used to test margin/alignments of a print job
  def test_page

    stroke_axis

    ["Courier", "Helvetica", "Times-Roman",
     "Courier-Bold", "Courier-Oblique", "Courier-BoldOblique",
     "Times-Bold", "Times-Italic", "Times-BoldItalic"].each do |font|
      font(font) do
        text "This is #{font} font", :size => 12
      end
    end

    [:mm, :cm, :dm, :m, :in, :yd, :ft].each do |measurement|
      text "1 #{measurement} in PDF Points: #{1.send(measurement)} pt"
      move_down 5.mm
    end


    stroke_color 'ff00000'
    stroke do
      # Right edge vertical lines
      vertical_line 100, 770, :at => 580
      vertical_line 100, 760, :at => 570
      vertical_line 100, 750, :at => 560
      # Left edge vertical lines
      vertical_line 100, 770, :at => 0
      vertical_line 100, 760, :at => 10
      vertical_line 100, 750, :at => 20
      # Top edge horizontal lines
      horizontal_line 0, 580, :at => 770
      horizontal_line 10, 570, :at => 760
      horizontal_line 20, 560, :at => 750
      # Bottom edge horizontal lines
      horizontal_line 0, 580, :at => 0
      horizontal_line 10, 570, :at => 10
      horizontal_line 20, 560, :at => 20
    end

    for size in 6..16
      font_size(size) { text "SmartKhata #{size}" }
    end

    text "This text is flowing from the left. " * 4

    move_down 15
    text "This text is flowing from the center. " * 3, :align => :center

    move_down 15
    text "This text is flowing from the right. " * 4, :align => :right

    move_down 15
    text "This text is justified. " * 6, :align => :justify
  end

  def print_coordinates
    # Absolute to the current bounding box
    text "top: #{bounds.top}"
    text "bottom: #{bounds.bottom}"
    text "left: #{bounds.left}"
    text "right: #{bounds.right}"

    move_down 10

    # Absolute to the page
    text "absolute top: #{sprintf "%.2f", bounds.absolute_top}"
    text "absolute bottom: #{sprintf "%.2f", bounds.absolute_bottom}"
    text "absolute left: #{sprintf "%.2f", bounds.absolute_left}"
    text "absolute right: #{sprintf "%.2f", bounds.absolute_right}"
  end

end
