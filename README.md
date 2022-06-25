# Alfred Automation Tasks

> **IMPORTANT:** Automation Tasks are one of the many new features of Alfred 5, [which is currently in Early Access](https://www.alfredapp.com/help/getting-started/early-access/). For the time being you need [a Workflow to install and update them](https://github.com/alfredapp/update-automation-tasks-workflow). By Alfred 5's General Release, the process will be automatic.

## How to use Automation Tasks

Open Alfred's Preferences to the Workflows preferences. In the Palette on the right, expand the Automations section and add an Automation Task object to your workflow.

## Setting up an Automation Task

Some objects are useful on their own. `Set Dark Mode`, for example:

<img width="365" alt="Hotkey connected to Set Dark Mode Automation Task" src="https://user-images.githubusercontent.com/1699443/175067230-dc9d04ab-0909-42c7-b3ee-46abe2399728.png">

But Automation Tasks shine when they're chained. A `Get Most Recently Added Path` of the Downloads folder connected to a `Send to Trash` deletes your most recent download:

<img width="536" alt="Hotkey and two Automation Tasks connected" src="https://user-images.githubusercontent.com/1699443/175067933-a5d303ac-2420-4b1a-911d-29b01fe7bae5.png">

We can do better. How about getting rid of all those downloaded DMGs you've accumulated?

<img width="720" alt="Hotkey and three Automation Tasks connected" src="https://user-images.githubusercontent.com/1699443/175067978-8f40e7ae-375e-4ab5-a285-e4510071f047.png">

* `List Folder Contents` of the Downloads folder.
* `Get Matching Arguments` set to match files ending in `.dmg`.
* Trash them.

Automation Tasks interact with other Alfred objects too. Let's play a random movie:

<img width="720" alt="Hotkey, two Automation Tasks, and Open File connected" src="https://user-images.githubusercontent.com/1699443/175068025-90bdaf1d-d2e2-4bab-9010-7b3596330e06.png">

* `List Folder Contents` of the Movies folder.
* `Get Random Argument` to pick one entry at chance.
* `Open File` to play it.

You're not limited to interacting with files. Automation Tasks can change your wallpaper, manipulate text and URLs, edit images, resize windows, interact with apps, and more! The list keeps growing. Grab [the demo Workflow](https://www.alfredapp.com/media/workflows/automation-tasks-examples.alfredworkflow) to play with the examples.
