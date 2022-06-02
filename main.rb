require 'rubygems'
require 'bundler/setup'
require 'heatmap'

require 'csv'

DATA_FILE_PATH = File.expand_path('~/Downloads/Blank Quiz.csv')

class Summary
  attr_accessor :ships_sunk

  def initialize(email)
    @email = email
    @cheated = false
    @ships_sunk = []
  end

  def cheater!
    self.cheated = true
  end

  def cheater?
    self.cheated
  end

  def hits?
    !self.ships_sunk.empty?
  end

  private

  attr_accessor :cheated
  attr_reader :email
end

# CRUISER = 1
# BATTLESHIP = 2
# DESTROYER = 3
# SUBMARINE = 4
# PATROL = 5
ANSWER = [
 # 1 2 3 4 5 6 7 8 9 10
  [0,0,0,0,0,0,0,4,0,0], # A
  [0,0,0,0,0,0,0,4,0,0], # B
  [0,0,0,0,0,0,0,4,0,0], # C
  [0,0,0,0,2,0,0,0,0,0], # D
  [0,3,0,0,2,0,0,0,0,0], # E
  [0,3,0,0,2,0,5,5,0,0], # F
  [0,3,0,0,2,0,0,0,0,0], # G
  [0,0,0,0,0,0,0,0,0,0], # H
  [0,0,0,0,1,1,1,1,1,0], # I
  [0,0,0,0,0,0,0,0,0,0], # J
]

csv = CSV.read(DATA_FILE_PATH, headers: true)

all_shots = {
  A: [],
  B: [],
  C: [],
  D: [],
  E: [],
  F: [],
  G: [],
  H: [],
  I: [],
  J: [],
}

summaries = []
csv.each do |row|
  summary = Summary.new(row['Username'])
  summaries << summary

  a_shots = row['Sink my battleship. You get 15 shots. [A]'].split(';').map(&:to_i)
  b_shots = row['Sink my battleship. You get 15 shots. [B]'].split(';').map(&:to_i)
  c_shots = row['Sink my battleship. You get 15 shots. [C]'].split(';').map(&:to_i)
  d_shots = row['Sink my battleship. You get 15 shots. [D]'].split(';').map(&:to_i)
  e_shots = row['Sink my battleship. You get 15 shots. [E]'].split(';').map(&:to_i)
  f_shots = row['Sink my battleship. You get 15 shots. [F]'].split(';').map(&:to_i)
  g_shots = row['Sink my battleship. You get 15 shots. [G]'].split(';').map(&:to_i)
  h_shots = row['Sink my battleship. You get 15 shots. [H]'].split(';').map(&:to_i)
  i_shots = row['Sink my battleship. You get 15 shots. [I]'].split(';').map(&:to_i)
  j_shots = row['Sink my battleship. You get 15 shots. [J]'].split(';').map(&:to_i)

  a_shots.each { |shot| all_shots[:A][shot] ||= 0 ; all_shots[:A][shot] += 1 }
  b_shots.each { |shot| all_shots[:B][shot] ||= 0 ; all_shots[:B][shot] += 1 }
  c_shots.each { |shot| all_shots[:C][shot] ||= 0 ; all_shots[:C][shot] += 1 }
  d_shots.each { |shot| all_shots[:D][shot] ||= 0 ; all_shots[:D][shot] += 1 }
  e_shots.each { |shot| all_shots[:E][shot] ||= 0 ; all_shots[:E][shot] += 1 }
  f_shots.each { |shot| all_shots[:F][shot] ||= 0 ; all_shots[:F][shot] += 1 }
  g_shots.each { |shot| all_shots[:G][shot] ||= 0 ; all_shots[:G][shot] += 1 }
  h_shots.each { |shot| all_shots[:H][shot] ||= 0 ; all_shots[:H][shot] += 1 }
  i_shots.each { |shot| all_shots[:I][shot] ||= 0 ; all_shots[:I][shot] += 1 }
  j_shots.each { |shot| all_shots[:J][shot] ||= 0 ; all_shots[:J][shot] += 1 }

  total_shots = a_shots.count + b_shots.count + c_shots.count + d_shots.count + e_shots.count + f_shots.count + g_shots.count + h_shots.count + i_shots.count + j_shots.count

  if total_shots > 15
    summary.cheater!
  end

  if i_shots.include?(5) && i_shots.include?(6) && i_shots.include?(7) && i_shots.include?(8) && i_shots.include?(9)
    summary.ships_sunk << 'cruiser'
  end
  if d_shots.include?(5) && e_shots.include?(5) && f_shots.include?(5) && g_shots.include?(5)
    summary.ships_sunk << 'battleship'
  end
  if e_shots.include?(2) && f_shots.include?(2) && g_shots.include?(2)
    summary.ships_sunk << 'destroyer'
  end
  if a_shots.include?(8) && b_shots.include?(8) && c_shots.include?(8)
    summary.ships_sunk << 'submarine'
  end
  if a_shots.include?(8) && b_shots.include?(8) && c_shots.include?(8)
    summary.ships_sunk << 'submarine'
  end
  if f_shots.include?(7) && f_shots.include?(8)
    summary.ships_sunk << 'patrol_boat'
  end
end

puts "\n\nCHEATERS - NO HITS\n\n"
summaries.select(&:cheater?).reject(&:hits?).each do |summary|
  p summary
end
puts "\n\nCHEATERS - HITS\n\n"
summaries.select(&:cheater?).select(&:hits?).each do |summary|
  p summary
end
puts "\n\nSAINTS - NO HITS\n\n"
summaries.reject(&:cheater?).reject(&:hits?).each do |summary|
  p summary
end
puts "\n\nSAINTS - HITS\n\n"
summaries.reject(&:cheater?).select(&:hits?).each do |summary|
  p summary
end

map = Heatmap.new
all_shots.each.with_index do |(_, shot_counts), grid_index|
  shot_counts.each.with_index do |shot_count, shot_index|
    (shot_count || 0).times do
      map << Heatmap::Area.new(grid_index * 60, shot_index * 60)
    end
  end
end
map.output('out/heatmap.png')
