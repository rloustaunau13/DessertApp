import SwiftUI

struct ContentView: View {
    @State private var desserts: [Dessert] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            List(desserts) { dessert in
                NavigationLink(destination: DetailView(dessertID: dessert.idMeal)) {
                    HStack {
                        AsyncImage(url: URL(string: dessert.strMealThumb)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 70)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 70)
                                .background(Color.gray)
                        }

                        Text(dessert.strMeal)
                            .bold()
                    }
                    .padding(3)
                }
            }
            .navigationTitle("Desserts")
            .onAppear {
                fetchDesserts()
            }
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
            }
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                    }
                }
            )
        }
    }

    private func fetchDesserts() {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            print("Invalid URL")
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Data is missing"
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(MealResponse.self, from: data)
                DispatchQueue.main.async {
                    desserts = response.meals
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}
