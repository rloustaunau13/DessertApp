import SwiftUI

struct DetailView: View {
    let dessertID: String
    @State private var dessertDetail: MealDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let dessertDetail = dessertDetail {
                AsyncImage(url: URL(string: dessertDetail.strMealThumb)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                } placeholder: {
                    ProgressView()
                }
                .padding()
                
                Text(dessertDetail.strMeal)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                Text("Instructions")
                .font(.headline)
                .padding([.top, .horizontal])

                Text(dessertDetail.strInstructions)
                .padding()
                .fixedSize(horizontal: false, vertical: true) // Ensure text wraps within the available space
                
                Text("Ingredients")
                .font(.headline)
                .padding([.top, .horizontal])
                // List of ingredients
                List {
                    ForEach(Array(zip(dessertDetail.ingredients, dessertDetail.measures)), id: \.0) { ingredient, measure in
                        Text("\(measure) \(ingredient)")
                    }
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            }

            Spacer()
        }
        .navigationTitle("Dessert Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchDessertDetail()
        }
    }

    private func fetchDessertDetail() {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(dessertID)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
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
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MealDetailResponse.self, from: data)
                DispatchQueue.main.async {
                    if let firstMeal = response.meals.first {
                        dessertDetail = firstMeal
                    } else {
                        errorMessage = "No meal details found"
                    }
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error)")
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}



