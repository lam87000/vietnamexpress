module ApplicationHelper
    # Méthode pour générer les créneaux horaires pour le menu déroulant
    def available_pickup_times
      # Génère des créneaux toutes les 15 minutes
      lunch_slots = generate_time_slots("12:00", "14:00", 15)
      dinner_slots = generate_time_slots("19:00", "21:30", 15)
  
      # Crée des groupes pour le menu déroulant avec des titres non-sélectionnables
      [
        ['--- MIDI ---', '', { disabled: true }],
        *lunch_slots.map { |time| [time, time] },
        ['--- SOIR ---', '', { disabled: true }],
        *dinner_slots.map { |time| [time, time] }
      ]
    end
  
    private
  
    # Petite méthode privée pour générer les listes de créneaux
    def generate_time_slots(start_time, end_time, interval_in_minutes)
      slots = []
      current_time = Time.zone.parse(start_time)
      end_time_parsed = Time.zone.parse(end_time)
  
      while current_time <= end_time_parsed
        slots << current_time.strftime("%H:%M")
        current_time += interval_in_minutes.minutes
      end
      
      slots
    end
  end