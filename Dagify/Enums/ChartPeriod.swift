//
//  ChartPeriodEnum.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//
enum ChartPeriod: String, CaseIterable, Identifiable {
    case harian = "Harian"
    case bulanan = "Bulanan"
    case tahunan = "Tahunan"
    var id: String { self.rawValue }
}
