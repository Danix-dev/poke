# R36S / ArkOS controller text-entry compatibility for Pokemon Essentials-family games.
#
# Many older Pokemon Essentials/Reborn/Rejuvenation games ship two text-entry modes:
#   USEKEYBOARD = true  -> physical keyboard + Input.gets
#   USEKEYBOARD = false -> built-in on-screen character grid controlled by gamepad
#
# R36S has no physical keyboard, so force the game's existing controller-friendly mode
# when the expected PokemonEntryScene class is present. On unrelated games this is a no-op.

begin
  if defined?(PokemonEntryScene) && PokemonEntryScene.const_defined?(:USEKEYBOARD)
    if PokemonEntryScene.const_get(:USEKEYBOARD)
      PokemonEntryScene.send(:remove_const, :USEKEYBOARD)
      PokemonEntryScene.const_set(:USEKEYBOARD, false)
      if defined?(System) && System.respond_to?(:puts)
        System.puts("[R36S] Controller text entry enabled (PokemonEntryScene::USEKEYBOARD=false)")
      end
    end
  end
rescue Exception => e
  if defined?(System) && System.respond_to?(:puts)
    System.puts("[R36S] Controller text-entry patch failed: #{e.class}: #{e.message}")
  end
end
