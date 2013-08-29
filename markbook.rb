#encoding: UTF-8

require 'sinatra'
require 'erb'

require File.join(File.dirname(__FILE__), "book_controller.rb")
include BookController

get '/' do
  list_of_chapters

  erb :list_chapters
end

get '/chapter/:chapter_order/assets/*.*' do |order, path, ext|
  send_file image_url(order.to_i, "#{path}.#{ext}")
end

get '/chapter/:chapter_order/*' do
  @content = compose_chapter params[:chapter_order]
  erb :show_chapter
end


__END__
