"""Public Path endpoints."""

from fastapi import APIRouter, HTTPException
from src.models import Path, PathConditions
from src.data import PATHS, CONDITIONS

router = APIRouter()


@router.get("", response_model=list[Path], operation_id="list_PATHS")
async def list_PATHS():
    """
    List all available hiking PATHS.
    
    Returns a list of all PATHS with basic information including
    difficulty, distance, and permit requirements.
    """
    return list(PATHS.values())


@router.get("/{Path_id}", response_model=Path, operation_id="get_Path")
async def get_Path(Path_id: str):
    """
    Get details for a specific Path.
    
    Returns Path details including difficulty, distance, elevation gain,
    estimated time, and whether a permit is required.
    """
    if Path_id not in PATHS:
        raise HTTPException(status_code=404, detail="Path not found")
    return PATHS[Path_id]


@router.get("/{Path_id}/conditions", response_model=PathConditions, operation_id="check_conditions")
async def check_conditions(Path_id: str):
    """
    Get current Path conditions and hazards.
    
    Returns:
    - Current status (open/closed/limited)
    - Active hazards and warnings
    - Weather conditions at Pathhead
    - Recent ranger notes and updates
    """    
    if Path_id not in CONDITIONS:
        raise HTTPException(status_code=404, detail="Path not found")
    return CONDITIONS[Path_id]
