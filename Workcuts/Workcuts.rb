require 'singleton'

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
		instance_eval &@action if !@action.nil?
	end
	
	def check
		@checked = true
	end
	
	def uncheck
		@checked = false
	end
	
	def to_s
		s = "<:" << self.identifier.to_s
		s << ",title=\"" << self.title << "\""
		s << ",key=" << self.key if !self.key.nil?
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

class WorkcutsShortcutProvider < OSX::NSObject
	include OSX
	def init
		super_init()
		self
	end
	def shortcuts
		WorkcutsShortcut.shortcuts
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
		#begin
			eval(str)
		#rescue Exception => exc
		#	OSX::NSLog("Planted")
		#end
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