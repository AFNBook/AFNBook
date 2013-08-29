# encoding: utf-8
require 'sinatra/base'

require 'pandoc-ruby' if development?

require 'redcarpet' # for markdown
require_relative 'lib/html_with_pygments.rb'

module BookController
  BOOK_DIR = File.join(File.dirname(__FILE__), 'book')
  CHAPTERS_DIR = File.join(BOOK_DIR, 'chapters')
  FILE_EXTENSION = '.md'

  def list_of_chapters
    pattern = File.join(CHAPTERS_DIR, '*')
    files = sorted_files_in pattern
    @chapters = files.collect {|file| File.directory?(file) ? File.basename(file) : nil}.compact
  end

  def sorted_files_in(path_pattern)
    Dir[path_pattern].sort!
  end

  def chapter_files_pattern chapter_index
    chapter_folder = list_of_chapters[chapter_index]
    File.join(CHAPTERS_DIR, chapter_folder, "*#{FILE_EXTENSION}")
  end


  def temporal_file_for_chapter chapter_index
    pathTmp = Tempfile.new('chapter_tmp')
    File.open(pathTmp, 'w') do |f|
      files = sorted_files_in chapter_files_pattern(chapter_index)
      files.each { |file_in_chapter| f << File.new(file_in_chapter).read + "\r\n\r\n" }
    end
    pathTmp
  end

  def render_to_markdown file_path
    content = File.open(file_path).read

    if settings.development?
      PandocRuby.convert(content, :from => :markdown, :to => :html)
    else
      render = Redcarpet::Markdown.new(HtmlWithPygments, fenced_code_blocks: TRUE)
      render.render(content)
    end
  end

  def compose_chapter chapter_index
    chapter_tmp = temporal_file_for_chapter chapter_index.to_i
    render_to_markdown chapter_tmp
  end

  def image_url(directory_index, img_name)
    File.join(CHAPTERS_DIR, list_of_chapters[directory_index], 'assets', img_name)
  end
end