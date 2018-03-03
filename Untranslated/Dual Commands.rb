#==============================================================================
# TheoAllen - Dual Command
# Version : 1.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_DualCMD] = true
#==============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Script ini adalah salah satu supporter untuk membuat dual language. Disini
  kamu bisa mengganti nama command dengan kata yang lain.
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main.
  Edit konfigurasinya ~
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.


}
#==============================================================================
# Konfigurasi
#==============================================================================
module Theo
  
  # Switch yang akan kamu gunakan untuk mengganti command (ON = diganti)
  Dual_Switch = 15
  
  # List nama command yang akan kamu ganti
  Dual_Commands = {
  
    "Special"     => "Spesial",
    "Magic"       => "Sihir",
    "Buy"         => "Beli",
    "Cancel"      => "Keluar",
    "To title"    => "Ke Judul",
    "Load Game"   => "Lanjutkan",
    
  }
  
end
#==============================================================================
# Script pendek dibawah ini jangan disentuh!
#==============================================================================
class Window_Command
  alias ed_dualcom_add_command add_command
  def add_command(name, symbol, enabled = true, ext = nil)
    name = Theo::Dual_Commands[name] if $game_switches[Theo::Dual_Switch] && 
      Theo::Dual_Commands[name]
    ed_dualcom_add_command(name, symbol, enabled, ext)
  end
end
