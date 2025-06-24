#!/usr/bin/env ruby

require 'fileutils'

class AdminImageOptimizer
  def initialize
    @source_dir = 'app/assets/images'
    @admin_dir = 'app/assets/images/admin'
    @quality = 30
    @optimized_count = 0
    @total_size_before = 0
    @total_size_after = 0
  end

  def optimize_all
    puts "🔧 OPTIMISATION IMAGES ADMIN - QUALITÉ #{@quality}%"
    puts "=" * 50
    
    create_admin_directory
    process_images
    generate_report
    cleanup_originals
  end

  private

  def create_admin_directory
    FileUtils.mkdir_p(@admin_dir)
    puts "📁 Dossier admin créé : #{@admin_dir}"
  end

  def process_images
    puts "\n🖼️  TRAITEMENT DES IMAGES"
    puts "-" * 30
    
    image_files = Dir.glob("#{@source_dir}/*.{jpg,jpeg,png,webp}")
    
    image_files.each do |source_file|
      next if source_file.include?('/admin/') # Skip déjà dans admin
      next if source_file.include?('_original') # Skip les backups
      
      process_single_image(source_file)
    end
  end

  def process_single_image(source_file)
    filename = File.basename(source_file)
    admin_file = File.join(@admin_dir, filename)
    
    # Taille avant
    size_before = File.size(source_file)
    @total_size_before += size_before
    
    # Optimisation avec sips (macOS)
    if system("which sips > /dev/null 2>&1")
      optimize_with_sips(source_file, admin_file)
    else
      # Fallback : copie simple si sips pas disponible
      FileUtils.cp(source_file, admin_file)
      puts "⚠️  sips non disponible, copie simple : #{filename}"
      return
    end
    
    # Vérifier si l'optimisation a réussi
    if File.exist?(admin_file)
      size_after = File.size(admin_file)
      @total_size_after += size_after
      @optimized_count += 1
      
      reduction = ((size_before - size_after).to_f / size_before * 100).round(1)
      size_before_kb = (size_before / 1024.0).round
      size_after_kb = (size_after / 1024.0).round
      
      puts "✅ #{filename}: #{size_before_kb}KB → #{size_after_kb}KB (-#{reduction}%)"
    else
      puts "❌ Échec optimisation : #{filename}"
    end
  end

  def optimize_with_sips(source_file, admin_file)
    # Commande sips pour optimiser à 30% de qualité
    command = "sips -s formatOptions #{@quality} '#{source_file}' --out '#{admin_file}' > /dev/null 2>&1"
    system(command)
  end

  def generate_report
    puts "\n📊 RAPPORT D'OPTIMISATION ADMIN"
    puts "=" * 50
    
    size_before_mb = (@total_size_before / 1024.0 / 1024.0).round(2)
    size_after_mb = (@total_size_after / 1024.0 / 1024.0).round(2)
    total_reduction = (@total_size_before - @total_size_after)
    reduction_mb = (total_reduction / 1024.0 / 1024.0).round(2)
    reduction_percent = (total_reduction.to_f / @total_size_before * 100).round(1)
    
    puts "Images optimisées: #{@optimized_count}"
    puts "Qualité appliquée: #{@quality}%"
    puts "Taille avant: #{size_before_mb}MB"
    puts "Taille après: #{size_after_mb}MB"
    puts "Économie: #{reduction_mb}MB (#{reduction_percent}%)"
    
    if @optimized_count > 0
      avg_size_before = (@total_size_before / @optimized_count / 1024.0).round
      avg_size_after = (@total_size_after / @optimized_count / 1024.0).round
      puts "Taille moyenne avant: #{avg_size_before}KB"
      puts "Taille moyenne après: #{avg_size_after}KB"
    end
    
    puts "\n🎯 PERFORMANCE ADMIN"
    puts "-" * 30
    estimate_loading_times(size_after_mb)
  end

  def estimate_loading_times(total_mb)
    connections = {
      'Fibre (100 Mbps)' => 100,
      '4G (20 Mbps)' => 20,
      '3G (5 Mbps)' => 5,
      'Edge (500 Kbps)' => 0.5
    }
    
    connections.each do |name, speed_mbps|
      time_seconds = (total_mb * 8) / speed_mbps
      
      status = case time_seconds
      when 0..0.5 then "🚀"
      when 0.5..2 then "✅"
      when 2..5 then "⚠️"
      else "❌"
      end
      
      if time_seconds < 1
        time_ms = (time_seconds * 1000).round
        puts "#{name}: #{time_ms}ms #{status}"
      else
        puts "#{name}: #{time_seconds.round(1)}s #{status}"
      end
    end
  end

  def cleanup_originals
    puts "\n🧹 NETTOYAGE"
    puts "-" * 30
    
    # Ne pas supprimer les originaux, juste informer
    puts "Images originales conservées dans: #{@source_dir}"
    puts "Images admin optimisées dans: #{@admin_dir}"
    puts "\n💡 Pour utiliser les images admin, modifiez les vues pour pointer vers /admin/"
  end
end

# Lancement du script
if __FILE__ == $0
  optimizer = AdminImageOptimizer.new
  optimizer.optimize_all
end 