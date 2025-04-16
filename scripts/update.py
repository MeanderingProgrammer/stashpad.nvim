from dataclasses import dataclass, field
from pathlib import Path

import tree_sitter_lua
from tree_sitter import Language, Node, Parser


@dataclass(frozen=True)
class LuaClass:
    value: str
    fields: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.fields.append(value)

    def exact(self) -> bool:
        return self.value.split()[1] == "(exact)"

    def config(self) -> bool:
        # ---@class stashpad.Init: stashpad.Api  -> stashpad.Init        -> Init
        # ---@class (exact) stashpad.Config      -> stashpad.Config      -> Config
        # ---@class (exact) stashpad.file.Config -> stashpad.file.Config -> Config
        full_name = self.value.split(":")[0].split()[-1]
        name = full_name.split(".")[-1]
        return name == "Config"

    def to_user(self) -> str:
        def user(s: str) -> str:
            return s.replace(".Config", ".UserConfig")

        lines: list[str] = [user(self.value)]
        for field in self.fields:
            field = user(field)
            name = field.split()[1]
            assert not name.endswith("?")
            field = field.replace(f" {name} ", f" {name}? ")
            lines.append(field)
        return "\n".join(lines)


def main() -> None:
    root = Path("lua/stashpad")
    update_types(root)


def update_types(root: Path) -> None:
    libs = list(root.joinpath("lib").iterdir())
    libs.sort(key=str)
    files: list[Path] = [root.joinpath("init.lua")] + libs

    classes: list[str] = ["---@meta"]
    for definition in get_definitions(files):
        if definition.exact() and definition.config():
            classes.append(definition.to_user())

    types = root.joinpath("types.lua")
    types.write_text("\n\n".join(classes) + "\n")


def get_definitions(files: list[Path]) -> list[LuaClass]:
    result: list[LuaClass] = []
    for file in files:
        for comment in ts_query(file, "(comment) @comment"):
            # ---@class (exact) stashpad.file.Config           -> class
            # ---@field extension fun(): string                -> field
            # ---@alias stashpad.project.Option 'remote'|'lsp' -> alias
            # ---@type stashpad.Config                         -> type
            # ---@param opts? stashpad.UserConfig              -> param
            annotation = comment.split()[0].split("@")[-1]
            if annotation == "class":
                result.append(LuaClass(comment))
            elif annotation == "field":
                result[-1].add(comment)
    return result


def ts_query(file: Path, query: str) -> list[str]:
    assert file.suffix == ".lua"

    language = Language(tree_sitter_lua.language())
    tree = Parser(language).parse(file.read_text().encode())
    captures = language.query(query).captures(tree.root_node)

    nodes: list[Node] = []
    for captured in captures.values():
        nodes.extend(captured)

    nodes.sort(key=lambda node: node.start_byte)
    texts = [node.text for node in nodes]
    return [text.decode() for text in texts if text is not None]


if __name__ == "__main__":
    main()
