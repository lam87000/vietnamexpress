#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'benchmark'
require 'json'

class PerformanceTest
  def initialize
    @base_url = 'http://localhost:3000'
    @results = {}
  end

  def run_all_tests
    puts "🔍 TEST DE PERFORMANCE - RESTAURANT LIMOGES"
    puts "=" * 50
    
    test_page_load_times
    test_image_loading
    calculate_total_size
    generate_report
  end

  private

  def test_page_load_times
    puts "\n📊 TEMPS DE CHARGEMENT DES PAGES"
    puts "-" * 30
    
    pages = {
      'Accueil' => '/',
      'Menu' => '/plats',
      'Commander' => '/commandes/new',
      'Admin' => '/admin/commandes'
    }
    
    pages.each do |name, path|
      time = measure_page_load(path)
      @results[name] = time
      status = time < 1.0 ? "✅" : time < 3.0 ? "⚠️" : "❌"
      puts "#{name}: #{(time * 1000).round}ms #{status}"
    end
  end

  def test_image_loading
    puts "\n🖼️  ANALYSE DES IMAGES"
    puts "-" * 30
    
    image_dir = 'app/assets/images'
    total_size = 0
    image_count = 0
    
    Dir.glob("#{image_dir}/*.{jpg,jpeg,png,webp}").each do |file|
      next if file.include?('_original')
      
      size = File.size(file)
      total_size += size
      image_count += 1
      
      size_kb = (size / 1024.0).round
      status = size_kb < 150 ? "✅" : size_kb < 300 ? "⚠️" : "❌"
      puts "#{File.basename(file)}: #{size_kb}KB #{status}"
    end
    
    @results['total_images'] = image_count
    @results['total_size_mb'] = (total_size / 1024.0 / 1024.0).round(2)
    @results['avg_size_kb'] = (total_size / 1024.0 / image_count).round
  end

  def calculate_total_size
    puts "\n📦 TAILLE TOTALE"
    puts "-" * 30
    
    puts "Nombre d'images: #{@results['total_images']}"
    puts "Taille totale: #{@results['total_size_mb']}MB"
    puts "Taille moyenne: #{@results['avg_size_kb']}KB"
  end

  def measure_page_load(path)
    uri = URI("#{@base_url}#{path}")
    
    time = Benchmark.realtime do
      begin
        Net::HTTP.get_response(uri)
      rescue => e
        puts "Erreur pour #{path}: #{e.message}"
        return 999.0
      end
    end
    
    time
  end

  def generate_report
    puts "\n🎯 RÉSULTAT FINAL"
    puts "=" * 50
    
    # Score pages
    page_score = calculate_page_score
    image_score = calculate_image_score
    
    total_score = ((page_score + image_score) / 2.0).round
    
    puts "Score Pages: #{page_score}/100"
    puts "Score Images: #{image_score}/100"
    puts "SCORE TOTAL: #{total_score}/100"
    
    grade = case total_score
    when 90..100 then "A+ 🏆"
    when 80..89 then "A 👍"
    when 70..79 then "B ⚠️"
    when 60..69 then "C 😐"
    else "D ❌"
    end
    
    puts "NOTE: #{grade}"
    
    # Temps de chargement estimés
    puts "\n⏱️  TEMPS DE CHARGEMENT ESTIMÉS"
    puts "-" * 30
    estimate_loading_times
  end

  def calculate_page_score
    avg_time = @results.values.select { |v| v.is_a?(Numeric) && v < 10 }.sum / 4.0
    score = case avg_time
    when 0..0.5 then 100
    when 0.5..1.0 then 90
    when 1.0..2.0 then 80
    when 2.0..3.0 then 70
    else 50
    end
    score
  end

  def calculate_image_score
    avg_size = @results['avg_size_kb']
    total_size = @results['total_size_mb']
    
    size_score = case avg_size
    when 0..100 then 100
    when 100..150 then 90
    when 150..200 then 80
    when 200..300 then 70
    else 50
    end
    
    total_score = case total_size
    when 0..2.0 then 100
    when 2.0..3.0 then 90
    when 3.0..5.0 then 80
    else 60
    end
    
    (size_score + total_score) / 2
  end

  def estimate_loading_times
    total_mb = @results['total_size_mb']
    
    connections = {
      'Fibre (100 Mbps)' => 100,
      '4G (20 Mbps)' => 20,
      '3G (5 Mbps)' => 5,
      'Edge (500 Kbps)' => 0.5
    }
    
    connections.each do |name, speed_mbps|
      time_seconds = (total_mb * 8) / speed_mbps
      time_ms = (time_seconds * 1000).round
      
      status = case time_seconds
      when 0..1 then "✅"
      when 1..5 then "⚠️"
      else "❌"
      end
      
      if time_seconds < 1
        puts "#{name}: #{time_ms}ms #{status}"
      else
        puts "#{name}: #{time_seconds.round(1)}s #{status}"
      end
    end
  end
end

# Lancement du test
if __FILE__ == $0
  tester = PerformanceTest.new
  tester.run_all_tests
end 