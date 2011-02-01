class RemoveDctermsValid < ActiveRecord::Migration
  def self.up
		# Remove bad dcterms_valid fields
    Action.scoped(:conditions => "dcterms_valid = 'donate'").all.each do |a|
      a.dcterms_valid = nil
      a.save
    end

    Action.scoped(:conditions => 'dcterms_valid IS NOT NULL').all.each do |a|
      dt = DateTime.parse(a.dcterms_valid.sub(/end=/, ''))
      p "#{a.id} #{a.dcterms_valid} #{dt}"
      a.expires_at = dt
      a.dcterms_valid = nil
      a.save
    end; nil

    remove_column :actions, :dcterms_valid
  end

  def self.down
    add_column :actions, :dcterms_valid, :string
  end
end
