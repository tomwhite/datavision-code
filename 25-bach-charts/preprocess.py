import pandas as pd
import pretty_midi

# Get all the composers and MIDI files from the metadata CSV
pieces = pd.read_csv('data/maestro-v2.0.0/maestro-v2.0.0.csv')
pieces = pieces[['canonical_composer', 'midi_filename']]
composers = pieces['canonical_composer'].unique()

# Create a dataframe for each composer that has note counts aggregated across all their pieces
dfs = []
for composer in composers:
    files = pieces[pieces["canonical_composer"] == composer]["midi_filename"].tolist()
    print(composer, len(files), "pieces")

    rows = {}
    i = 0
    for file in files:
        midi_data = pretty_midi.PrettyMIDI(f'data/maestro-v2.0.0/{file}')
        for instrument in midi_data.instruments:
            for note in instrument.notes:
                note_name = pretty_midi.note_number_to_name(note.pitch)
                rows[i] = [note.pitch, note_name, note.velocity, note.duration]
                i = i + 1

    df = pd.DataFrame.from_dict(rows, orient='index',
                        columns=['pitch', 'note', 'velocity', 'duration'])
    df = df.groupby(['note']).size().reset_index(name='count')
    df[composer] = df["count"]
    df = df[["note", composer]]
    #print(df)
    dfs.append(df)

# Merge the per-composer dataframes into a single dataframe, where rows are notes, columns are composers
merged = dfs[0]
for df in dfs[1:]:
    merged = pd.merge(merged, df, how="outer", on="note", right_index=False, left_index=False)

# Sum counts for all composers
merged["All"] = merged.iloc[:, 1:].sum(axis=1)
print(merged)

# Save as CSV
merged.to_csv("data/note_counts_by_composer.csv", index=False)

# Find note proportions for each composer and save as CSV
normalized = merged.iloc[:, 1:] / merged.iloc[:, 1:].sum()
normalized.insert(0, "note", merged["note"]) # add back note column in first position
print(normalized)
normalized.to_csv("data/note_proportions_by_composer.csv", index=False)
