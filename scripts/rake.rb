require 'sinatra'
require_relative '../book_controller.rb'

ENV['tmp'] = File.join(ENV['book_folder'], 'tmp')
ENV['assets'] = File.join(ENV['tmp'], 'assets')
ENV['tmp_file'] = "merged.md"


def go_to_root_folder
  Dir.chdir ENV['root']
end

def prepare_content
  remove_temporal_files

  FileUtils.mkpath ENV['assets'] # it includes both folders (output and assets)

  merge_text_files
  copy_assets
end

def merge_text_files
  File.open(File.join(ENV['tmp'], ENV['tmp_file']), 'w+') do |f|
    Dir["book/chapters/*/*.md"].each do |file|
      f << File.new(file).read + "\r\n\r\n"
      puts "Merging #{file}" if DEBUG
    end
  end
end

def copy_assets
  Dir.chdir ENV['book_folder']
  Dir["chapters/*/assets/*.png"].each do |file|
    FileUtils.copy file, File.join(ENV['assets'], File.basename(file)), verbose: DEBUG
  end

  FileUtils.copy ENV['metadata_file'], File.join(ENV['tmp'], ENV['metadata_file']) if File.exist? ENV['metadata_file']
  FileUtils.copy ENV['cover_file'], File.join(ENV['tmp'], ENV['cover_file']) if File.exist? ENV['cover_file']

  go_to_root_folder
end

def remove_temporal_files
  FileUtils.remove_dir ENV['tmp'], force: TRUE
end

def generate_epub
  Dir.chdir ENV['tmp']
  output_file = File.join(ENV['book_folder'], ENV['epub_file'])

  command = "pandoc -s"
  command << " --epub-metadata=" + ENV['metadata_file'] if File.exist? ENV['metadata_file']
  command << " --epub-cover-image=#{ENV['cover_file']}" if File.exist? ENV['cover_file']
  command << " -o #{output_file}"
  command << " #{ENV['tmp_file']}"
  `#{command}`
  puts command if DEBUG

  puts "Generado: #{output_file}"

  go_to_root_folder
end