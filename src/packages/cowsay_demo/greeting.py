import cowsay

from packages.message_demo.message import (
    build_default_greet_message_from_env,
    build_greet_message,
)


def greet_to(your_name: str) -> None:
    """_summary_

    Args:
        your_name (str): _description_
    """
    greet = build_greet_message(your_name=your_name)
    print(cowsay.get_output_string(text=greet, char="cow"))


def greet_from_env() -> None:
    """_summary_

    Args:
        your_name (str): _description_
    """
    greet = build_default_greet_message_from_env()
    print(cowsay.get_output_string(text=greet, char="cow"))
