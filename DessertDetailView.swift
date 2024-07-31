
import SwiftUI

struct DessertDetailView: View {
    let dessert: Dessert
    @State private var mealDetail: mealDetail?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let mealDetail = mealDetail {
                ScrollView {
                    AsyncImage(url: URL(string: mealDetail.strMealThumb)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 250)
                            .background(Color.gray)
                    }
                    
                    Text(mealDetail.strMeal)
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(mealDetail.strInstructions)
                        .padding()

                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top)

                    ForEach(getIngredients(), id: \.self) { ingredient in
                        Text(ingredient)
                            .padding(.horizontal)
                    }
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            }
        }
        .navigationTitle("Dessert Details")
        .onAppear {
            fetchMealDetail()
        }
    }
    
    private func fetchMealDetail() {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(dessert.idMeal)") else {
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
                if let meal = response.meals.first {
                    DispatchQueue.main.async {
                        mealDetail = mealDetail
                        isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
    
    private func getIngredients() -> [String] {
        guard let mealDetail = mealDetail else { return [] }
        
        var ingredients: [String] = []
        let mirror = Mirror(reflecting: mealDetail)
        for child in mirror.children {
            if let label = child.label, label.hasPrefix("strIngredient"), let value = child.value as? String, !value.isEmpty {
                ingredients.append(value)
            }
        }
        return ingredients
    }
}
