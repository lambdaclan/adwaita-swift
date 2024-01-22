//
//  ComboRow+.swift
//  Adwaita
//
//  Created by david-swift on 20.01.24.
//

import CAdw
import LevenshteinTransformations

/// A row for selecting an element out of a list of elements.
extension ComboRow {

    static var values: String { "values" }
    static var stringList: String { "string-list" }

    /// Initialize a combo row.
    /// - Parameters:
    ///     - title: The row's title.
    ///     - selection: The selected value.
    ///     - values: The available values.
    public init<Element>(
        _ title: String,
        selection: Binding<Element.ID>,
        values: [Element]
    ) where Element: Identifiable, Element: CustomStringConvertible {
        self = self.title(title)
        self = self.selected(.init {
            .init(values.firstIndex { $0.id == selection.wrappedValue } ?? 0)
        } set: { index in
            if let id = values[safe: .init(index)]?.id {
                selection.wrappedValue = id
            }
        })
        appearFunctions.append { storage in
            let list = gtk_string_list_new(nil)
            storage.fields[Self.stringList] = list
            adw_combo_row_set_model(storage.pointer?.cast(), list)
        }
        updateFunctions.append { storage in
            if let list = storage.fields[Self.stringList] as? OpaquePointer {
                let old = storage.fields[Self.values] as? [Element] ?? []
                var new = values.filter { element in !old.contains { $0.id == element.id } }
                new = old + new
                old.identifiableTransform(
                    to: new,
                    functions: .init { index, element in
                        gtk_string_list_remove(list, .init(index))
                        gtk_string_list_append(list, element.description)
                    } delete: { index in
                        gtk_string_list_remove(list, .init(index))
                    } insert: { _, element in
                        gtk_string_list_append(list, element.description)
                    }
                )
                storage.fields[Self.values] = new
            }
        }
    }

}
