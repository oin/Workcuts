#
#  WorkcutsKey.rb
#  Workcuts
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

require 'osx/cocoa'

class WorkcutsKey
	attr_accessor :key, :modifier
	
	def initialize(s)
		@key = ""
		@modifier = []
		
		s.split.each do |k|
			if k.downcase == "space" or k.downcase == "spc"
				@key = " "
			elsif k.downcase == "return" or k.downcase == "enter"
				@key = "\r"
			elsif k.downcase == "command" or k.downcase == "cmd"
				@modifier << OSX::NSCommandKeyMask
			elsif k.downcase == "option" or k.downcase == "opt" or k.downcase == "alt"
				@modifier << OSX::NSAlternateKeyMask
			elsif k.downcase == "control" or k.downcase == "ctrl"
				@modifier << OSX::NSControlKeyMask
			elsif k.downcase == "shift" or k.downcase == "maj"
				@modifier << OSX::NSShiftKeyMask
			elsif %w(Insert Delete Home Begin End PageUp PageDown PrintScreen ScrollLock Pause SysReq Break Reset Stop Menu User System Print).include? k
				@key = eval("OSX::NS"+k+"FunctionKey.chr")
				@modifier << OSX::NSFunctionKeyMask
			elsif %w(Up Down Left Right).include? k
				eval("@key = OSX::NS"+k+"ArrowFunctionKey.chr")
				@modifier << OSX::NSFunctionKeyMask
			elsif %w(Tab Backspace Enter Delete).include? k
				eval("@key = OSX::NS"+k+"Character.chr")
			elsif %w(F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 F25 F26 F27 F28 F29 F30 F31 F32 F33 F34 F35).include? k
				eval("@key = OSX::NS"+k+"FunctionKey.chr")
				@modifier << OSX::NSFunctionKeyMask
			else
				@key = k
			end
		end
	end
	def to_s
		"Key:" + @key + " (modifiers:" + @modifier.to_s + ")"
	end
end