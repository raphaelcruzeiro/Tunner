//
//  NoteMapper.swift
//  TunnerKit
//
//  Created by Raphael Cruzeiro on 11/02/2017.
//  Copyright © 2017 Raphael Cruzeiro. All rights reserved.
//

import Foundation

class NoteMapper {
    
    private let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    private let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    private let twelthRootOfTwo = pow(Double(2), 1/12)
    
    var referenceFrequency: Double = 440
    let minimumFrequency: Double = 25
    
    var frequencyTable = [Note]()
    
    struct Note {
        var nameWithSharp: String
        var nameWithFlat: String
        var frequency: Double
        var octave: Int
    }
    
    init(referenceFrequency: Double = 440) {
        self.referenceFrequency = referenceFrequency
        calculateFrequencyTable()
    }
    
    private func calculateFrequencyTable() {
        calculateBaseFrequency()
        
        let referenceA = Note(
            nameWithSharp: "A",
            nameWithFlat: "A",
            frequency: referenceFrequency,
            octave: 0
        )
        
        let first = calculateNote(from: referenceA, halfSteps: -9)
        
        frequencyTable.append(first)
        
        func recursiveCalculation() {
            let previous = frequencyTable.last!
            let next = calculateNote(from: previous, halfSteps: 1)
            frequencyTable.append(next)
            
            if !(next.nameWithSharp == "B" && next.octave == 8) {
                recursiveCalculation()
            }
        }
        
        recursiveCalculation()
    }
    
    func calculateNote(from: Note, halfSteps: Int) -> Note {
        let fromNoteNameIndex = noteNamesWithSharps.index(of: from.nameWithSharp)!
        let frequency = from.frequency * pow(twelthRootOfTwo, Double(halfSteps))
        var nameIndex = fromNoteNameIndex + halfSteps
        var octave = from.octave
        
        while nameIndex < 0 || nameIndex >= noteNamesWithSharps.count {
            if nameIndex < 0  {
                nameIndex = noteNamesWithSharps.count + nameIndex
                octave -= 1
            }
            else if nameIndex >= noteNamesWithSharps.count {
                nameIndex = nameIndex - noteNamesWithSharps.count
                octave += 1
            }
        }
        
        return Note(
            nameWithSharp: noteNamesWithSharps[nameIndex],
            nameWithFlat: noteNamesWithFlats[nameIndex],
            frequency: frequency,
            octave: octave
        )
    }
    
    func note(for frequency: Double) -> Note {
        let closestMatch = frequencyTable.reduce(frequencyTable.first!) { prev, next in
            if abs(prev.frequency - frequency) < abs(next.frequency - frequency) {
                return prev
            }
            return next
        }
        
        return closestMatch
    }
    
    private func calculateBaseFrequency() {
        let lowerOctave = referenceFrequency / 2
        if lowerOctave < minimumFrequency {
            return
        }
        referenceFrequency = lowerOctave
        calculateFrequencyTable()
    }
}
