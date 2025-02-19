//
//  ContentView.swift
//  BetterRest
//
//  Created by Seth Barnard on 2/17/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var suggestedWakeTime: Date {
        var suggestion = Date.now
        do {
            let model = try SleepCalculator(configuration: MLModelConfiguration())
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            suggestion = wakeUp - prediction.actualSleep
        } catch {
            print("Error on ml calc")
        }
        return suggestion;
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake?")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Recommended Bed Time: \(suggestedWakeTime.formatted(date: .omitted, time: .shortened))")
                    
                }
            }
            .navigationTitle("Better Rest")

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
