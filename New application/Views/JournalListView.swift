import SwiftUI
import SwiftData

struct JournalListView: View {
    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var entries: [JournalEntry]

    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var showingEditor = false
    @State private var entryToEdit: JournalEntry?
    @State private var searchText = ""
    @State private var entryToDelete: JournalEntry?

    private var filteredEntries: [JournalEntry] {
        guard !searchText.isEmpty else { return entries }
        let query = searchText.lowercased()
        return entries.filter { entry in
            entry.content.lowercased().contains(query)
            || entry.mood.label.lowercased().contains(query)
            || entry.tags.contains { $0.lowercased().contains(query) }
        }
    }

    /// Entries grouped by date section, ordered: Today -> Yesterday -> This Week -> Earlier
    private var groupedEntries: [(key: String, entries: [JournalEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { $0.createdAt.sectionKey }
        return grouped
            .map { (key: $0.key, entries: $0.value) }
            .sorted {
                ($0.entries.first?.createdAt.sectionSortOrder ?? 99)
                    < ($1.entries.first?.createdAt.sectionSortOrder ?? 99)
            }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                if entries.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        // Greeting header
                        Section {
                            GreetingHeader()
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }

                        ForEach(groupedEntries, id: \.key) { section in
                            Section {
                                ForEach(section.entries) { entry in
                                    Button {
                                        navigationPath.append(entry.id)
                                    } label: {
                                        JournalEntryCard(entry: entry)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            entryToDelete = entry
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .contextMenu {
                                        Button {
                                            entryToEdit = entry
                                            showingEditor = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }

                                        Button(role: .destructive) {
                                            entryToDelete = entry
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text(section.key)
                                    .font(Typography.caption)
                                    .foregroundStyle(Color.reflectTextTertiary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(
                        text: $searchText,
                        prompt: "Search entries..."
                    )
                    .padding(.bottom, 60)
                }

                FloatingComposeButton {
                    entryToEdit = nil
                    showingEditor = true
                }
            }
            .navigationDestination(for: UUID.self) { entryID in
                if let entry = entries.first(where: { $0.id == entryID }) {
                    JournalDetailView(entry: entry) {
                        entryToEdit = entry
                        showingEditor = true
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                JournalEditorView(entry: entryToEdit)
                    .id(entryToEdit?.id)
            }
            .alert(
                "Delete Entry",
                isPresented: .init(
                    get: { entryToDelete != nil },
                    set: { if !$0 { entryToDelete = nil } }
                )
            ) {
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        withAnimation {
                            modelContext.delete(entry)
                        }
                        entryToDelete = nil
                    }
                }
            } message: {
                Text("This entry will be permanently deleted.")
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    JournalListView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
