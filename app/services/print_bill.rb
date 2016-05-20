class PrintBill < Prawn::Document

  require 'prawn/table'

  def initialize
    super(top_margin: 0, left_margin: 0)
    text "Brooo!"

    stroke_axis

    text "cursor 1 #{cursor}"
    text "cursor 2 #{cursor}"

    move_down 200
    text "down"

    move_up 100
    text "up"
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