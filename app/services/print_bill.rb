class PrintBill < Prawn::Document
  # TODO(sarojk)
  # Set papaer size to Letter
  # And shrink to fit

  require 'prawn/table'
  require 'prawn/measurement_extensions'

  def initialize
    # super(top_margin: 13, right_margin: 13, bottom_margin: 13, left_margin: 13)
    super(top_margin: 14, right_margin: 13, bottom_margin: 13, left_margin: 18)

    # stroke_horizontal_rule
    # font_size(6) {text "Horizontal Ruler 1"}
    # stroke_horizontal_rule
    # font_size(6) {text "Horizontal Ruler 2"}
    # stroke_horizontal_rule
    # font_size(6) {text "Horizontal Ruler 3"}


    # float do
    #   move_down 30
    #   bounding_box([0, cursor], :width => 200) do
    #     text "Text inside float block #{cursor}"
    #     stroke_bounds
    #   end
    # end

    # text "This text should be left aligned"
    # text "This text should be centered",      :align => :center
    # text "This text should be right aligned", :align => :right
    # text "This text should be bottom aligned", :valign => :bottom
    # text "This text should be top aligned", :valign => :top
    # text "This text should be ceneter aligned vertically", :valign => :center


    stroke_axis

    bounding_box([0, 770], :width => 580, :height => 220) do
      text "This text is flowing from the left. " * 4

      move_down 15
      text "This text is flowing from the center. " * 3, :align => :center

      move_down 15
      text "This text is flowing from the right. " * 4, :align => :right

      move_down 15
      text "This text is justified. " * 6, :align => :justify
      transparent(0.5) { stroke_bounds }
    end

    start_new_page
    stroke_axis

    text "This text should be vertically top aligned"
    text "This text should be vertically centered",       :valign => :center
    text "This text should be vertically bottom aligned", :valign => :bottom

    start_new_page
    stroke_axis

    ["Courier", "Helvetica", "Times-Roman",
     "Courier-Bold", "Courier-Oblique", "Courier-BoldOblique",
     "Times-Bold", "Times-Italic", "Times-BoldItalic"].each do |font|
      font(font) do
        text "This is #{font} font", :size=>12
      end
    end

    # [:mm, :cm, :dm, :m, :in, :yd, :ft].each do |measurement|
    #   text "1 #{measurement} in PDF Points: #{1.send(measurement)} pt"
    #   move_down 5.mm
    # end


    stroke_color "ff00000"
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
      font_size(size) {text "SmartKhata #{size}"}
    end

    text "This text is flowing from the left. " * 4

    move_down 15
    text "This text is flowing from the center. " * 3, :align => :center

    move_down 15
    text "This text is flowing from the right. " * 4, :align => :right

    move_down 15
    text "This text is justified. " * 6, :align => :justify

  end

  def header

  end

  def text_content_dummy

  end

  def text_content(name, boid, broker)

  end

  def table_content(data)

  end

  def product_rows

  end

end
