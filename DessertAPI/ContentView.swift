
import SwiftUI

// Define the Dessert model
struct Dessert: Hashable, Codable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

struct mealDetail:Hashable, Codable {
    let idMeal:String
    let strMeal:String
    let strMealThumb:String
    let strInstructions:String
    let ingredients:[String]
    let measures:[String]
}

// Define the structure for the API response
struct MealResponse: Codable {
    let meals: [Dessert]
}

struct ContentView: View{
    @State private var desserts: [Dessert] = []
      @State private var isLoading: Bool = false
      @State private var errorMessage: String?
    
var body: some View {
        NavigationView {
            List(desserts, id: \.idMeal) { dessert in
                NavigationLink(destination: DetailView(dessert: dessert)) { // Wrap HStack in NavigationLink
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
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error?.localizedDescription
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MealResponse.self, from: data)
                DispatchQueue.main.async {
                    desserts = response.meals.sorted{$0.strMeal<$1.strMeal}
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

#Preview {
    ContentView()
}
