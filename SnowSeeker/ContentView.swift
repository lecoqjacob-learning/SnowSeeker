//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Jacob LeCoq on 3/5/21.
//

import SwiftUI

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

enum FilterType {
    case def, alphabetical, country
}

class ResortFilter: ObservableObject {
    @Published var selections: [String] = ["All"]
    var by: KeyPath<Resort, String>
    
    init(by: KeyPath<Resort, String>) {
        self.by = by
    }
    
    func filter(_ list: [Resort]) -> [Resort] {
        if (selections.contains("All")){
            return list
        }
        
        return list.filter { selections.contains($0[keyPath: by]) }
    }
}

class ResortFilters: ObservableObject {
    @Published var filters: [ResortFilter]
    
    init(_ filters: [ResortFilter]){
        self.filters = filters
    }
}

struct ContentView: View {
    @ObservedObject var favorites = Favorites()
    
    @State var showingSheet: Bool = false
    @State var sortSelection = SortType.defaultSort
    @State var countriesSelection = ["All"]
    @State var sizesSelection = ["All"]
    @State var pricesSelection = ["All"]
    @ObservedObject var resortFilters: ResortFilters = ResortFilters([ResortFilter(by: \.country)])
        
    let resorts: [Resort] = Resort.allResorts
    
    var sortedResults: [Resort] {
        switch sortSelection {
        case .country:
            return self.resorts.sorted(by: \.country)
        case .name:
            return self.resorts.sorted(by: \.name)
        default:
            return self.resorts
        }
    }
    
    var filteredResults: [Resort] {
        var list = sortedResults
        
        print("here")
        print(resortFilters.filters[0].selections)
        resortFilters.filters.forEach { filter in
            list = filter.filter(list)
        }
        
        print(list.count)
        
        return list
    }
    
//    func filterBy(_ list: [Resort], selectionList: [String], filterBy: KeyPath<Resort, String>) -> [Resort] {
//        if (selectionList.contains("All")){
//            return list
//        }
//
//        return list.filter{ selectionList.contains( $0[keyPath: filterBy])}
//    }

    var body: some View {
        NavigationView {
            List(filteredResults) { resort in
                NavigationLink(destination: ResortView(resort: resort)) {
                    Image(resort.country)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 25)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                        )

                    VStack(alignment: .leading) {
                        Text(resort.name)
                            .font(.headline)
                        Text("\(resort.runs) runs")
                            .foregroundColor(.secondary)
                    }
                    .fixedSize(horizontal: true, vertical: true)

                    if self.favorites.contains(resort) {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .accessibility(label: Text("This is a favorite resort"))
                            .foregroundColor(Color.red)
                    }
                }
            }
            // challenge 3
            .sheet(isPresented: $showingSheet, onDismiss: { self.resortFilters.objectWillChange.send() }, content: {
                SortAndFilterView(resorts: self.resorts,
                                  sortSelection: self.$sortSelection,
                                  countriesSelection: self.$countriesSelection,
                                  sizesSelection: self.$sizesSelection,
                                  pricesSelection: self.$pricesSelection)
            })
            .navigationBarTitle("Resorts")
            .navigationBarItems(trailing: Button(action: {
                self.showingSheet = true
            }, label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down.circle")
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                // increase tap area size
                .padding(15)
            })
            )

            WelcomeView()
        }
        .environmentObject(favorites)
        .environmentObject(resortFilters)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
