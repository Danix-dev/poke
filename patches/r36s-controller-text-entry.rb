# R36S / ArkOS controller-friendly text entry for Pokemon Essentials-family games.
#
# Modern Pokemon Essentials chooses the naming/text-entry scene in pbEnterText:
#   $PokemonSystem.textinput == 1 -> physical keyboard
#   otherwise                     -> controller/cursor character grid
#
# On R36S there is no physical keyboard. Wrap pbEnterText and temporarily force
# cursor mode only while the text-entry scene is open. The user's saved setting
# is restored afterwards.
#
# Older Essentials variants are handled by the USEKEYBOARD fallback below.
# Unrelated games are left untouched.

begin
  if respond_to?(:pbEnterText, true)
    unless respond_to?(:r36s_pbEnterText_original, true)
      alias r36s_pbEnterText_original pbEnterText

      def pbEnterText(*args, &block)
        changed = false
        old_value = nil

        begin
          if defined?($PokemonSystem) && $PokemonSystem &&
             $PokemonSystem.respond_to?(:textinput) &&
             $PokemonSystem.respond_to?(:textinput=)
            old_value = $PokemonSystem.textinput
            $PokemonSystem.textinput = 0
            changed = true
          end

          r36s_pbEnterText_original(*args, &block)
        ensure
          if changed && defined?($PokemonSystem) && $PokemonSystem &&
             $PokemonSystem.respond_to?(:textinput=)
            $PokemonSystem.textinput = old_value
          end
        end
      end
    end
  end

  # Fallback for older Essentials/Reborn/Rejuvenation-style implementations.
  if defined?(PokemonEntryScene) && PokemonEntryScene.const_defined?(:USEKEYBOARD)
    if PokemonEntryScene.const_get(:USEKEYBOARD)
      PokemonEntryScene.send(:remove_const, :USEKEYBOARD)
      PokemonEntryScene.const_set(:USEKEYBOARD, false)
    end
  end

  if defined?(System) && System.respond_to?(:puts)
    System.puts("[R36S] Controller text-entry compatibility patch loaded")
  end
rescue Exception => e
  if defined?(System) && System.respond_to?(:puts)
    System.puts("[R36S] Controller text-entry patch failed: #{e.class}: #{e.message}")
  end
end
