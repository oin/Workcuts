#
#  Workcuts.rb
#  Workcuts
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

require 'singleton'
require 'stringio'

module Workcuts
	@@shortcuts = []
	
	def self.shortcuts
		@@shortcuts
	end
end

require 'WorkcutsKey'

class Shortcut
	attr_accessor :identifier, :title, :key, :action, :checked, :alternate
	
	def initialize(identifier)
		@identifier = identifier
		@title = @identifier.to_s
		@key = WorkcutsKey.new("")
		@action = nil
		@checked = false
		@alternate = false
	end
	
	def named(str)
		@title = str
	end
	
	def press(str)
		@key = WorkcutsKey.new str
	end
	
	def will(&block)
		@action = block
	end
	
	def alternative
		@alternate = true
	end
	
	def noalternative
		@alternate = false
	end
	
	def execute
		if !@action.nil?
			fstdout = $stdout
			fstderr = $stderr
			$stdout = StringIO.new
			$stderr = StringIO.new
			begin
				instance_eval &@action
				# Send a success notification
				OSX::NSNotificationCenter.defaultCenter.postNotificationName_object_userInfo_("WorkcutsEvalSuccess", self, { "stdout" => $stdout.string + $stderr.string })
			rescue Exception => exc
				# Format the error
				errorName = $!.to_s
				errorString = $@.join("\n")
				# Send an error notification
				OSX::NSNotificationCenter.defaultCenter.postNotificationName_object_userInfo_("WorkcutsEvalError", self, { "name" => errorName, "error" => errorString})
			end
			$stderr = fstderr
			$stdout = fstdout
		end
	end
	
	def check
		@checked = true
	end
	
	def uncheck
		@checked = false
	end
	
	def toggle
		@checked = !@checked
	end
	
	def to_s
		s = "<:" << self.identifier.to_s
		s << ",title=\"" << self.title << "\""
		s << ",key=" << self.key.to_s if !self.key.nil?
		s << ",checked" if self.checked
		s << ",folds" if self.alternate
		s << ">"
	end
end

def shortcut(identifier, &block)
	found = Workcuts::shortcuts.find { |s| s.identifier == identifier }
	if found.nil?
		found = Shortcut.new identifier
		Workcuts::shortcuts << found
	end
	found.instance_eval &block if block_given?
end

def terminal(script, exitafter = false, pressreturn = false)
	# Fetch the settings set from user preferences
	settingsset = OSX::NSUserDefaults.standardUserDefaults["TerminalSettingsSet"]
	# Create the Applescript
	applescript = "tell application \"Terminal\"\n"
	applescript << "\tactivate\n"
	applescript << "\tdo script \"" << "cd \\\"" << $WorkcutsPath << "\\\" && clear; " << script << "; echo"
	applescript << "; exit" if exitafter
	applescript << "\"\n"
	applescript << "\tset current settings of first tab of first window to settings set \"" << settingsset << "\"\n"
	applescript << "end tell\n"
	if pressreturn
		applescript << "delay 1\n"
		applescript << "tell application \"System Events\"\n"
		applescript << "\tkey code 36\n"
		applescript << "end tell\n"
	end
	# Execute
	asexec = OSX::NSAppleScript.alloc.initWithSource_(applescript)
	asexec.executeAndReturnError_(nil)
end

class WorkcutsShortcutProvider < OSX::NSObject
	include OSX
	def init
		super_init()
		self
	end
	def shortcuts
		WorkcutsShortcut.shortcuts
	end
	def setpath(s)
		$WorkcutsPath = s
		Dir.chdir(s)
	end
	def evaluate(str)
		WorkcutsShortcut.evaluate(str)
	end
	def clear
		Workcuts::shortcuts.clear
	end
end

class WorkcutsShortcut < OSX::NSObject
	include OSX
	
	def self.shortcuts
		Workcuts::shortcuts.map { |s| WorkcutsShortcut.alloc.initWithShortcutIdentifier(s.identifier.to_s) }
	end
	
	def self.evaluate(str)
		begin
			Kernel.class_eval(str)
			NSNotificationCenter.defaultCenter.postNotificationName_object_userInfo_("WorkcutsEvalSuccess", self, nil)
		rescue Exception => exc
			# Format the error
			errorName = $!.to_s
			errorString = $@.join("\n")
			# Send an error notification
			NSNotificationCenter.defaultCenter.postNotificationName_object_userInfo_("WorkcutsEvalError", self, { "name" => errorName, "error" => errorString})
		end
	end
	
	def initialize
		@shortcut = nil
	end
	
	def initWithShortcutIdentifier(i)
		@shortcut = Workcuts::shortcuts.find { |s| s.identifier.to_s == i }
		self
	end
	
	def identifier
		@shortcut.identifier.to_s
	end
	
	def title
		@shortcut.title
	end
	
	def keyEquivalent
		@shortcut.key.key
	end
	
	def keyEquivalentModifier
		@shortcut.key.modifier.inject(0){|v,x| v + x}
	end
	
	def checked
		@shortcut.checked
	end
	
	def alternate
		@shortcut.alternate
	end
	
	def execute
		@shortcut.execute
	end
end