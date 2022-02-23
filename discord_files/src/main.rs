use discord_game_sdk::{
    Discord,
    CreateFlags,
    Activity,
    EventHandler,
};

struct BreadEventHandler {}
impl BreadEventHandler{
    fn new() -> BreadEventHandler {
        BreadEventHandler {}
    }
}
impl EventHandler for BreadEventHandler {}

enum GameMode {
    TITLE,
    IN_SONG,
    PAUSED
}

struct GameState {
    score : i64,
    current_song : String,
    current_mode : GameMode,
    end_time : i64,
    cheats : char
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut discord = Discord::with_create_flags(945567902180970546, CreateFlags::NoRequireDiscord)?;
    *discord.event_handler_mut() = Some(BreadEventHandler::new());
    let mut game_state = GameState {
        score : 30i64,
        current_song : "Loadout".to_string(),
        current_mode : GameMode::TITLE,
        end_time : 1645606225i64,
        cheats : 0b11011000 as char,
    };
    discord.update_activity(
        &Activity::empty()
            .with_large_image_key("gameicon")
            .with_small_image_key("loadouticon")
            .with_state(&("Score: ".to_owned() + &game_state.score.to_string()))
            .with_end_time(game_state.end_time)
            .with_details(&game_state.current_song),
        |discord, result| {
            if let Err(error) = result {
                eprintln!("failed to update activity: {}", error);
            }
        },
    );
    loop {
        std::thread::sleep(std::time::Duration::from_millis(16));
        discord.run_callbacks()?;
        println!("callbacks ran");
    }
    Ok(())
}
