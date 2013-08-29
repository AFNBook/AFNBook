require 'pygments.rb'

class HtmlWithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language, options: {linenos: FALSE})
  end
end