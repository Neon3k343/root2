////
////  ReviewScreen.swift
////  Instants camera
////
////  Created by Hubert  Greszta on 17/08/2026.
////
//
//import SwiftUI
//import _SwiftData_SwiftUI
//
//public extension Color {
//
//    #if os(macOS)
//    static let background = Color(NSColor.windowBackgroundColor)
//    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
//    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
//    #else
//    static let background = Color(UIColor.systemBackground)
//    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
//    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
//    #endif
//}
//
//struct ReviewScreen: View {
//    
//    @Query private var reviews: [Review]
//    @Environment(\.modelContext) private var modelContext
//    @State private var newName = ""
//    @State private var newContent = ""
//    @State private var randomReviewCount: Int = .random(in: 0...10000)
//    @State private var isChecked = true
//    
//    var body: some View {
//        ZStack {
//            Color(.systemBackground)
//                .ignoresSafeArea()
//            VStack(alignment: .leading, spacing: 10) {
//                
//                Image("Eclipse")
//                    .resizable()
//                    .scaledToFit()
//                    .clipped()
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                
//                HStack {
//                    Text("Eclipse")
//                        .bold()
//                        .font(.title)
//                    
//                    Spacer()
//                    
//                    Text("\(randomReviewCount) Reviews")
//                        .foregroundStyle(.blue)
//                    
//                    
//                }
//                VStack{
//                    HStack {
//                        TextField("Name", text: $newName)
//                            .textFieldStyle(.roundedBorder)
//                        Image(systemName: "star")
//                        Image(systemName: "star")
//                        Image(systemName: "star")
//                        Image(systemName: "star")
//                        Image(systemName: "star")
//                    }
//                    HStack {
//                        TextField("What do you think about this?", text: $newContent)
//                            .textFieldStyle(.roundedBorder)
//                        Button("Add") {
//                            addReview()
//                        }
//                        .buttonStyle(.glassProminent)
//                        .disabled((newName).isEmpty)
//                    }
//                }
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                List{
//                    ForEach(reviews){ review in
//                        VStack{
//                            HStack{
//                                Image(systemName: "star.fill")
//                                    .foregroundColor(.yellow)
//                                    .font(.system(size: 20))
//                                
//                                Spacer()
//                                
//                                Text(review.name)
//                            }
//                            HStack{
//                                Text(review.content)
//                                    .strikethrough(review.isReviewed)
//                                
//                                Spacer()
//                                
//                                Image(systemName: review.isReviewed ? "checkmark.circle.fill" : "circle")
//                                    .contentTransition(.symbolEffect)
//                                    .onTapGesture {
//                                        isChecked.toggle()
//                                        toggleReview(review)
//                                    }
//                            }
//                        }
//                        .opacity(review.isReviewed ? 0.3 : 1)
//                        .onTapGesture {
//                            toggleReview(review)
//                        }
//                    }
//                    .onDelete(perform: deleteReviews)
//                    .backgroundStyle(Color.white)
//                }
//                
//            }
//            
//            .padding()
//        }
//    }
//    
//    private func addReview() {
//        let newReview = Review(name: newName, content: newContent, rating: .random(in: 1...5))
//        modelContext.insert(newReview)
//        newName = ""
//        newContent = ""
//    }
//    
//    private func toggleReview(_ review: Review) {
//        review.isReviewed.toggle()
//    }
//    
//    private func deleteReviews(at offsets: IndexSet) {
//        for index in offsets {
//            modelContext.delete(reviews[index])
//        }
//    }
//}
//
//#Preview {
//    ReviewScreen()
//        .modelContainer(for: Review.self, inMemory: true)
//}
