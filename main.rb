require 'sinatra'
require 'slim'
require 'redcarpet' # for markdown
require 'pygments.rb'


APP_DIR     = File.join(File.join(File.dirname(__FILE__)))
VIEWS_DIR   = File.join(APP_DIR, "views")
ASSETS_DIR  = File.join(VIEWS_DIR, "assets")

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language, options: {linenos: true})
  end
end


# set the appropriate options for markdown
#set :markdown, :renderer => Redcarpet::Markdown.new(HtmlWithPygments,
#    :fenced_code_blocks => true, :layout_engine => :slim)


def get_files
	dir = Dir.pwd + '/views/posts'
	files = []
	if File.directory?(dir)
		Dir.foreach("#{dir}") do |item|
	 		next if item == '.' or item == '..'
	 		files << File.basename(item, '.*')
		end
	end
	files
end

get '/' do
	@files = get_files
	markdown :README
end


get %r{(.*)/([\w]+).(jpg|jpeg|png)} do
  image = File.join(ASSETS_DIR, params[:captures][1..2].join('.'))
  send_file(image)
end


get '/post/:dir' do
	@files = get_files
	begin
    puts "Intentando cargar: posts/#{params[:dir]}"
    contenido = File.open(File.join(VIEWS_DIR, 'posts' , params[:dir] + '.md')).read

    render = Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
	rescue Errno::ENOENT => e
		p "No encontrado el fichero"
    p e
  end

  <<-prueba
<head>
  <style>
  #{Pygments.css(style: 'manni')}
  </style>
</head>

<div>
  #{render.render(contenido)}
</div>
  prueba


end