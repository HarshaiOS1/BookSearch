//
//  ContentView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI
import CoreData
import Lottie

struct ContentView: View {
    @ObservedObject private var viewModel: BooksViewModel
    
    init(viewModel: BooksViewModel) {
        self.viewModel = viewModel
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            if !viewModel.isConnected {
                VStack(alignment: .center , content: {
                    LottieView(filename: "NoInternet", isPaused: false)
                    Text("No Internet Connection")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button("Load Offline Data") {
                        loadOfflineData()
                    }
                    .buttonStyle(.bordered)
                })
                Spacer()
                    .padding(.bottom, 150)
            }
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            //hit api here
            print(searchText)
        }
        .navigationBarTitle("Books", displayMode: .large)
    }
    
    private func loadOfflineData() {
        print("adsfafdf")
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView(viewModel: BooksViewModel(googleBookServices: FetchBookAPI())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
